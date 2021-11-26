function out = eq(a,b)
  % Overload the '==' operator for we_DataType objects
  % =========================================================================
  % Bryan Guillaume
  % Version Info:  2020-06-18 15:16:32 +0200 0153229

  out = strcmp(a.value, b.value);

end
