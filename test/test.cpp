#include "CppUTest/TestHarness.h"
#include "my_module.h"

TEST_GROUP(TestExamples)
{
};

TEST(TestExamples, FirstExample)
{
  int x = my_func();
  CHECK_EQUAL(1, x);
}
