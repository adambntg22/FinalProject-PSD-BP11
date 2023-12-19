library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity atm_machine is
    port (
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
        money_out : out integer;
    );
end entity atm_machine;

architecture rtl of atm_machine is
    TYPE state_type is (IDLE, PIN_CHANGE, ENTER_PIN, ATTEMPT_PIN_1, ATTEMPT_PIN_2, ATTEMPT_PIN_3, READY, DEPOSIT, WITHDRAWAL);
    SIGNAL state : state_type;
    SIGNAL AccPin1 : password_type := (1, 8, 2, 5, 3, 1); -- PIN milik akun 00 adalah 182531
    SIGNAL AccPin2 : password_type := (7, 0, 8, 8, 1, 2); -- PIN milik akun 01 adalah 708812
    SIGNAL AccPin3 : password_type := (6, 1, 9, 2, 7, 4); -- PIN milik akun 10 adalah 619274
    SIGNAL AccPin4 : password_type := (3, 5, 1, 4, 9, 9); -- PIN milik akun 11 adalah 351499
    SIGNAL balance_database : balance_type := (100_000, 80_000, 0, 2_000); -- Database balance sesuai index akun

    -- pinDatabase(0) = PIN akun 1 -> 182531 (PIN awal)
    -- pinDatabase(1) = PIN akun 2 -> 708812 (PIN awal)
    -- pinDatabase(2) = PIN akun 3 -> 619274 (PIN awal)
    -- pinDatabase(3) = PIN akun 4 -> 351499 (PIN awal)
    SIGNAL pinDatabase : passwordArrays := (AccPin1, AccPin2, AccPin3, AccPin4);

    SIGNAL encryptedPin : STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL passwordUsage : password_type;

    SIGNAL accountUsageIndex : integer;
    SIGNAL accountUsageIndexID : integer;
    SIGNAL userBalanc : integer;
    SIGNAL new_pin : password_type;
    SIGNAL moneyChange : integer;
    SIGNAL moneyOut : integer;
    SIGNAL newBalanceAfterDeposit : integer;
    SIGNAL newBalanceAfterWithdrawal : integer;

    component encryption is 
        port(
            pin_code : in password_type;
            clock : in std_logic;

            encrypted_pin_code : out STD_LOGIC_VECTOR(55 DOWNTO 0)

        );
    end component encryption;

    component pin_changer is
        port(
            clock : in std_logic;
            old_pin : in password_type;
            new_pin_input : in password_type;
            new_pin : out password_type;  
        );
    end component pin_changer;

    component deposit is 
        port(
            clock : in std_logic;
            oldBalance : in integer;
            nominal : in integer;
            deposit : in integer;
            but_pecahan : in STD_LOGIC_VECTOR(6 DOWNTO 0);
            newBalance : out integer;
            change : out integer
        );
    end component deposit;

    component withdraw is 
        port(
            clock : in std_logic;
            withdraw_nominal : in integer;
            oldBalance : in integer;
            buttonAmount : in button_amount := (0, 0, 0, 0, 0, 0, 0);
            reset : in std_logic;
            newBalance : out integer;
            output : out integer
        );
    end component withdraw;

begin

    if accountUsageIndexID := 0 then 
        pin_input = pinDatabase(0)
    elsif accountUsageIndexID := 1 then 
        pin_input = pinDatabase(1)
    elsif accountUsageIndexID := 2 then 
        pin_input = pinDatabase(2)
    elsif accountUsageIndexID := 3 then 
        pin_input = pinDatabase(3)
    else 
        0;


    balanceUser <= balance_database(0) when accountUsageIndexID = 0 else
                balance_database(1) when accountUsageIndexID = 1 else
                balance_database(2) when accountUsageIndexID = 2 else
                balance_database(3) when accountUsageIndexID = 3 else
                0;
    
    
    
    
end architecture rtl;