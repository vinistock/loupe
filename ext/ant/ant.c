#include "ant.h"

VALUE rb_mAnt;

void
Init_ant(void)
{
  rb_mAnt = rb_define_module("Ant");
}
