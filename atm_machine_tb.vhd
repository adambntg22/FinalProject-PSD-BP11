LIBRARY ieee, work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.atm_prototypes.ALL;

entity atm_machine_tb is
end entity atm_machine_tb;

architecture rtl of atm_machine_tb is
  COMPONENT atm_machine IS
    PORT (
        clock : in std_logic;
        reset : in std_logic;
        card_reader : in std_logic;
        pin_input : in password_type;
        new_pin_input : in password_type;

        --BUTTONS ATM
        deposit_button : in std_logic;
        withdraw_button : in std_logic;
        continue_button : in std_logic;
        change_pin_button : in std_logic;

        --NOMINAL
        deposit_nominal : in integer;
        withdraw_nominal : in integer;
        machine_nominal : in integer;

        buttonDeposit : in std_logic_vector(6 downto 0);
        buttonAmountWithdraw : in button_amount;

        --OUTPUT 
        money_out : out integer
    );
  end COMPONENT atm_machine;

  CONSTANT t : TIME := 30 ns;
  
  signal clock : STD_LOGIC;
  SIGNAL reset : STD_LOGIC;
  SIGNAL card_reader : STD_LOGIC := '1';
  SIGNAL pin_input : password_type := (1, 8, 2, 5, 3, 1);
  SIGNAL new_pin_input : password_type := (3, 1, 8 , 0, 1, 2);
  SIGNAL deposit_button : STD_LOGIC := '1';
  SIGNAL withdraw_button : STD_LOGIC := '0';
  SIGNAL change_pin_button : STD_LOGIC := '0';
  SIGNAL continue_button : STD_LOGIC := '1';
  SIGNAL machine_nominal : INTEGER := 30_000;
  SIGNAL withdraw_nominal : INTEGER := 30_000;
  SIGNAL deposit_nominal : INTEGER := 25_000;
  SIGNAL buttonDeposit : std_logic_vector(6 DOWNTO 0) := "0000100";
  SIGNAL buttonAmountWithdraw : button_amount := (1, 2, 0, 0, 0, 0, 0);
  SIGNAL money_out : INTEGER;


begin
  DUT_Deposit : atm_machine PORT MAP(
    clock => clock, reset => reset, card_reader => card_reader, pin_input => pin_input,
    new_pin_input => new_pin_input, deposit_button => deposit_button,
    withdraw_button => withdraw_button, change_pin_button => change_pin_button,
    continue_button => continue_button, machine_nominal => machine_nominal,
    withdraw_nominal => withdraw_nominal, deposit_nominal => deposit_nominal,
    buttonDeposit => buttonDeposit, buttonAmountWithdraw => buttonAmountWithdraw,
    money_out => money_out
  );

  PROCESS
  BEGIN
    clock <= '0';
    WAIT FOR T/2;
    clock <= '1';
    WAIT FOR T/2;
  END PROCESS;

  reset <= '1', '0' AFTER T/2;
end architecture;