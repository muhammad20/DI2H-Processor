Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity StackPointer is
  port (
    clk, addOne, addTwo, subOne, subTwo, reset : in std_logic;
    value : out std_logic_vector(31 downto 0)
  );
end StackPointer;


architecture archEntity of StackPointer is
    signal addTwoOutput, addOneOutput, subOneOutput, subTwoOutput, registerValue : std_logic_vector(31 downto 0);
    Signal addControl : std_logic_vector(3 downto 0);
begin

    addTwoOutput <= std_logic_vector(unsigned(registerValue) + 2);
    addOneOutput <= std_logic_vector(unsigned(registerValue) + 1);
    subOneOutput <= std_logic_vector(unsigned(registerValue) - 1);
    subTwoOutput <= std_logic_vector(unsigned(registerValue) - 2);

    addControl <= addOne & addTwo & subOne & subTwo;
    
    process (clk, reset) 
    begin
        if(reset = '1' ) then
            value <= std_logic_vector(to_unsigned(1048575, 32));
            registerValue <= std_logic_vector(to_unsigned(1048575, 32));
        elsif (rising_edge(clk)) then
            case(addControl) is
                when "1000" => registerValue <= addOneOutput;
                                value <= addOneOutput;
                when "0100" => registerValue <= addTwoOutput;
                                value <= addTwoOutput;
                when "0010" => registerValue <= subOneOutput;
                                value <= subOneOutput;
                when "0001" => registerValue <= subTwoOutput;
                                value <= subTwoOutput;
                when others => value <= registerValue;
            end case ;

        end if;
    end process;

end archEntity ; -- archEntity