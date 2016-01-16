/*
** mrb_expat.c - Expat class
**
** Copyright (c) bamchoh 2016
**
** See Copyright Notice in LICENSE
*/

#include "mruby.h"
#include "mruby/data.h"
#include "mruby/string.h"
#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/variable.h"
#include "mrb_expat.h"
#include "expat.h"

#define DONE mrb_gc_arena_restore(mrb, 0);

#if defined(__amigaos__) && defined(__USE_INLINE__)
#include <proto/expat.h>
#endif

#ifdef XML_LARGE_SIZE
#if defined(XML_USE_MSC_EXTENSIONS) && _MSC_VER < 1400
#define XML_FMT_INT_MOD "I64"
#else
#define XML_FMT_INT_MOD "ll"
#endif
#else
#define XML_FMT_INT_MOD "l"
#endif

typedef struct {
  mrb_state *mrb;
  mrb_value self;
  int depth;
  mrb_value prev_text;
} mrb_expat_data;

static const struct mrb_data_type mrb_expat_data_type = {
  "mrb_expat_data", mrb_free,
};

void
internal_detect_text(mrb_expat_data *exp_data)
{
  struct RString *s = mrb_str_ptr(exp_data->prev_text);
  if(RSTR_LEN(s) != 0)
  {
    mrb_funcall(exp_data->mrb, exp_data->self, "__sys_detect_text__", 1, exp_data->prev_text);
    exp_data->prev_text = mrb_str_new(exp_data->mrb, 0, 0);
  }
}

static void XMLCALL
start_element(void *user_data, const char *name, const char **attributes)
{
  mrb_expat_data *exp_data = (mrb_expat_data *)user_data;
  mrb_value str;
  mrb_value attrs;

  internal_detect_text(exp_data);

  str   = mrb_str_new(exp_data->mrb, name, strlen(name));
  attrs = mrb_hash_new(exp_data->mrb);

  for (int i = 0; attributes[i]; i += 2)
  {
      mrb_value key = mrb_str_new(exp_data->mrb, attributes[i],   strlen(attributes[i]));
      mrb_value val = mrb_str_new(exp_data->mrb, attributes[i+1], strlen(attributes[i+1]));
      mrb_hash_set(exp_data->mrb, attrs, key, val);
  }

  mrb_funcall(exp_data->mrb, exp_data->self, "__sys_start_element__", 2, str, attrs);

  exp_data->depth += 1;
}

static void XMLCALL
end_element(void *userData, const char *name)
{
  mrb_expat_data *exp_data = (mrb_expat_data *)userData;
  mrb_value str;

  internal_detect_text(exp_data);

  str = mrb_str_new(exp_data->mrb, name, strlen(name));
  mrb_funcall(exp_data->mrb, exp_data->self, "__sys_end_element__", 1, str);

  exp_data->depth -= 1;
}

static void XMLCALL
value_handler(void *user_data, const XML_Char *c, int len)
{
  mrb_expat_data *exp_data = (mrb_expat_data *)user_data;

  mrb_value str = mrb_str_new(exp_data->mrb, c, len);
  struct RString *s = mrb_str_ptr(exp_data->prev_text);
  if(RSTR_LEN(s) == 0)
  {
    exp_data->prev_text = str;
  }
  else
  {
    exp_data->prev_text = mrb_str_plus(exp_data->mrb, exp_data->prev_text, str);
  }
}

static void XMLCALL
start_cdata(void *user_data)
{
  // mrb_expat_data *exp_data = (mrb_expat_data *)user_data;
}

static void XMLCALL
end_cdata(void *user_data)
{
  // mrb_expat_data *exp_data = (mrb_expat_data *)user_data;
}

static mrb_value mrb_expat_parse(mrb_state *mrb, mrb_value self)
{
  struct RString *xml_str;
  mrb_value xml_text;
  mrb_expat_data *exp_data;
  XML_Parser parser = XML_ParserCreate(NULL);
  int done;
  int len = 0;

  mrb_get_args(mrb, "S", &xml_text);

  xml_str = mrb_str_ptr(xml_text);

  exp_data = (mrb_expat_data *)mrb_malloc(mrb, sizeof(mrb_expat_data));
  memset(exp_data, 0, sizeof(mrb_expat_data));
  exp_data->mrb = mrb;
  exp_data->self = self;
  exp_data->depth = 0;
  exp_data->prev_text = mrb_str_new(mrb, 0, 0);
  XML_SetUserData(parser, exp_data);
  XML_SetElementHandler(parser, start_element, end_element);
  XML_SetCharacterDataHandler(parser, value_handler);
  XML_SetCdataSectionHandler(parser, start_cdata, end_cdata);
  do {
    len = RSTR_LEN(xml_str) - len;
    done = len < RSTR_LEN(xml_str);
    if (XML_Parse(parser, RSTR_PTR(xml_str), len, done) == XML_STATUS_ERROR) {
      struct RClass *exception = mrb_class_get(mrb, "XmlParserError");

      mrb_value msg = mrb_str_new(mrb,
          XML_ErrorString(XML_GetErrorCode(parser)),
          strlen(XML_ErrorString(XML_GetErrorCode(parser))));

      mrb_value line = mrb_fixnum_value(XML_GetCurrentLineNumber(parser));

      mrb_raisef(mrb, exception, "%S at line %S", msg, line);

      return mrb_nil_value();
    }
  } while (!done);
  XML_ParserFree(parser);

  return mrb_funcall(mrb, self, "root", 0);
}

void mrb_mruby_expat_gem_init(mrb_state *mrb)
{
    struct RClass *expat;
    expat = mrb_define_class(mrb, "XmlParser", mrb->object_class);
    mrb_define_method(mrb, expat, "__sys_parse__", mrb_expat_parse, MRB_ARGS_REQ(1));
    DONE;
}

void mrb_mruby_expat_gem_final(mrb_state *mrb)
{
}

