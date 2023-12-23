LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.atm_prototypes.ALL;

ENTITY pin_changer IS
  PORT (
    clock : in std_logic;
    old_pin : in password_type;
    new_pin_input : in password_type;
    new_pin : out password_type
  );
END ENTITY pin_changer;

ARCHITECTURE rtl OF pin_changer IS
  SIGNAL TEMP_NEW : password_type;
BEGIN
  PROCESS (clock)
  BEGIN
    FOR i IN 0 TO 5 LOOP
      TEMP_NEW(i) <= NEW_PIN_INPUT(i);
    END LOOP;
  END PROCESS;
  NEW_PIN <= TEMP_NEW;
END ARCHITECTURE;