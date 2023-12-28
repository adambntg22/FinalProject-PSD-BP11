LIBRARY IEEE, work;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.atm_prototypes.ALL;

ENTITY withdraw IS
  PORT (
    clock : IN STD_LOGIC;
    withdraw_nominal : IN INTEGER;
    oldBalance : IN INTEGER;
    buttonAmount : IN button_amount := (0, 0, 0, 0, 0, 0, 0);
    reset : IN STD_LOGIC;
    newBalance : OUT INTEGER;
    output : OUT INTEGER
  );
END ENTITY withdraw;

ARCHITECTURE behavior_withdraw OF withdraw IS

  SIGNAL State, Nextstate : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL wd_sum : INTEGER := 0;

BEGIN
  PROCESS (clock, State, reset)
  BEGIN
    IF (rising_edge(clock)) THEN
      CASE (State) IS
        WHEN 0 =>
          wd_sum <= 0;
          IF (withdraw_nominal > 0) THEN
            Nextstate <= 1;
          ELSE
            Nextstate <= 0;
          END IF;
        WHEN 1 =>
          IF (oldBalance >= withdraw_nominal) THEN
            -- ButtomAmount(0) untuk pecahan 1000
            -- ButtomAmount(1) untuk pecahan 2000
            -- ButtomAmount(2) untuk pecahan 5000
            -- ButtomAmount(3) untuk pecahan 10000
            -- ButtomAmount(4) untuk pecahan 20000
            -- ButtomAmount(5) untuk pecahan 50000
            -- ButtomAmount(6) untuk pecahan 100000
            wd_sum <= (buttonAmount(0) * 1_000) + (buttonAmount(1) * 2_000) + (buttonAmount(2) * 5_000) + (buttonAmount(3) * 10_000) + (buttonAmount(4) * 20_000) + (buttonAmount(5) * 50_000) + (buttonAmount(6) * 100_000);
            Nextstate <= 2;
          ELSIF (oldBalance < withdraw_nominal) THEN
            wd_sum <= 0;
            Nextstate <= 1;
          ELSE
            Nextstate <= 1;
          END IF;
        WHEN 2 =>
          IF (wd_sum = withdraw_nominal) THEN
            Nextstate <= 3;
          ELSE
            Nextstate <= 1;
          END IF;
        WHEN 3 =>
          Nextstate <= 0;
        WHEN OTHERS =>
          Nextstate <= 0;
      END CASE;
    END IF;
  END PROCESS;

  newBalance <= oldBalance - wd_sum;
  output <= wd_sum;

  PROCESS (clock, Nextstate, reset)
  BEGIN
    IF(reset = '1') THEN
      State <= 0;
    ELSIF(rising_edge(clock)) THEN
      State <= Nextstate;
    END IF;
  END PROCESS;
END behavior_withdraw;