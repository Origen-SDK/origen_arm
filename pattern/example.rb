Pattern.create do
  # Registers should never be written directly from here, always call API methods
  # that are defined by your controllers
  dut.cm33.do_something
end
