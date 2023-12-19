library IEEE, work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.atm_prototypes.ALL;

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
        money_out : out integer
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
    SIGNAL userBalance : integer;
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
            new_pin : out password_type
        );
    end component pin_changer;

    component depositC is 
        port(
            clock : in std_logic;
            oldBalance : in integer;
            nominal : in integer;
            deposit : in integer;
            but_pecahan : in STD_LOGIC_VECTOR(6 DOWNTO 0);
            newBalance : out integer;
            change : out integer
        );
    end component depositC;

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

    accountUsageIndexID <= 0 WHEN PIN_INPUT = pinDatabase(0) ELSE
                         1 WHEN PIN_INPUT = pinDatabase(1) ELSE
                         2 WHEN PIN_INPUT = pinDatabase(2) ELSE
                         3 WHEN PIN_INPUT = pinDatabase(3) ELSE
                         0;


    userBalance <= balance_database(0) when accountUsageIndexID = 0 else
                balance_database(1) when accountUsageIndexID = 1 else
                balance_database(2) when accountUsageIndexID = 2 else
                balance_database(3) when accountUsageIndexID = 3 else
                0;

    ENCRYPT_PIN : encryption port map(passwordUsage, clock, encryptedPin);
    CHANGING_PIN : pin_changer port map(clock, passwordUsage, new_pin_input, new_pin);
    DEPOSIT_PROC : depositC port map(clock, userBalance, machine_nominal, deposit_nominal, buttonDeposit, newBalanceAfterDeposit, moneyChange);
    WITHDRAW_PROC : withdraw port map(clock, withdraw_nominal, userBalance, buttonAmountWithdraw, reset, newBalanceAfterWithdrawal, moneyOut);
    
    onUsage : PROCESS (clock, deposit_button, withdraw_button, change_pin_button, reset)
        VARIABLE buttonPressed: STD_LOGIC_VECTOR(2 downto 0);
        VARIABLE validAccount : STD_LOGIC;
        BEGIN
        IF (reset = '1') THEN
            state <= IDLE;
        ELSIF (RISING_EDGE(clock)) THEN
            CASE STATE IS
                WHEN IDLE =>
                    passwordUsage <= (0, 0, 0, 0, 0, 0);
                    IF (CARD_READER = '1') THEN
                        STATE <= ENTER_PIN;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN ENTER_PIN =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = pinDatabase(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= pinDatabase(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= ATTEMPT_PIN_1;
                    END IF;
                WHEN ATTEMPT_PIN_1 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = pinDatabase(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= pinDatabase(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= ATTEMPT_PIN_2;
                    END IF;
                WHEN ATTEMPT_PIN_2 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = pinDatabase(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= pinDatabase(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= ATTEMPT_PIN_3;
                    END IF;
                WHEN ATTEMPT_PIN_3 =>
                    FOR accountUsageIndex in 0 to 3 loop
                        IF(PIN_INPUT = pinDatabase(accountUsageIndex)) THEN
                            validAccount := '1';
                            passwordUsage <= pinDatabase(accountUsageIndex);
                            exit;
                        ELSE 
                            validAccount := '0';
                        END IF;
                    end loop;
                    IF(validAccount = '1') THEN
                        -- PANGGIL 
                        -- COMPONENT ENCRYPTION
                        -- DI SINI
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN READY =>
                    buttonPressed := deposit_button & withdraw_button & change_pin_button;
                    IF(buttonPressed = "100") THEN
                        -- STATE DEPOSIT
                        STATE <= DEPOSIT;
                    ELSIF(buttonPressed = "010") THEN 
                        -- STATE WITHDRAWAL
                        STATE <= WITHDRAWAL;
                    ELSIF(buttonPressed = "001") THEN
                        -- STATE CHANGE_PIN_BUTTON
                        STATE <= PIN_CHANGE;
                    ELSE 
                        STATE <= READY;
                    END IF;
                WHEN DEPOSIT =>
                    -- MEMANGGIL
                    -- DEPOSIT COMPONENT
                    -- DI SINI
                    IF(userBalance = balance_database(0)) THEN
                        balance_database(0) <= newBalanceAfterDeposit;
                    ELSIF(userBalance = balance_database(1)) THEN
                        balance_database(1) <= newBalanceAfterDeposit;
                    ELSIF(userBalance = balance_database(2)) THEN
                        balance_database(2) <= newBalanceAfterDeposit;
                    ELSIF(userBalance = balance_database(3)) THEN
                        balance_database(3) <= newBalanceAfterDeposit;
                    END IF;
                    MONEY_OUT <= moneyChange; 
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN WITHDRAWAL =>
                    -- MEMANGGIL
                    -- WITHDRAWAL COMPONENT
                    -- DI SINI
                    IF(userBalance = balance_database(0)) THEN
                        balance_database(0) <= newBalanceAfterWithdrawal;
                    ELSIF(userBalance = balance_database(1)) THEN
                        balance_database(1) <= newBalanceAfterWithdrawal;
                    ELSIF(userBalance = balance_database(2)) THEN
                        balance_database(2) <= newBalanceAfterWithdrawal;
                    ELSIF(userBalance = balance_database(3)) THEN
                        balance_database(3) <= newBalanceAfterWithdrawal;
                    END IF;
                    MONEY_OUT <= moneyOut; 
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE
                        STATE <= IDLE;
                    END IF;
                WHEN PIN_CHANGE =>
                    -- MEMANGGIL
                    -- PIN CHANGE COMPONENT
                    -- DI SINI
                    IF(accountUsageIndexID = 0) THEN
                        AccPin1 <= new_pin;
                    ELSIF(accountUsageIndexID = 1) THEN
                        AccPin2 <= new_pin;
                    ELSIF(accountUsageIndexID = 2) THEN
                        AccPin3 <= new_pin;
                    ELSIF(accountUsageIndexID = 3) THEN
                        AccPin4 <= new_pin;
                    END IF;
                    IF(CONTINUE_BUTTON = '1') THEN
                        STATE <= READY;
                    ELSE 
                        STATE <= IDLE;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
end architecture rtl;