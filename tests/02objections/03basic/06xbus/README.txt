In this example, a new obj_example_seq is written that raises an objection in
the pre_body(), performs its work in the body() then drops the objection in
the post_body().  The test sets the default sequence to obj_example_seq and
associates a drain time with the test of 200.
