with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Strings;
procedure kursova2 is
	N: integer := 500;	-- Size of our Matrixes
	P: integer := 4;		-- Number of processors
	H: integer := N/P;	-- Number of threads
	type Matrix is array (1..N,1..N) of integer;
	MA, MB, MC, MK, MCK: Matrix;

protected Control is
	entry wait_for_input;
	entry wait_for_calc;
	entry wait_for_calc_2;
	procedure SIG_INP;
	procedure SIG_CLC_1;
	procedure SIG_CLC_2;
private
	x: integer;
	F1: integer:=0;
	F2: integer:=0;
	F3: integer:=0;
end Control;

-- body

protected body Control is
	entry wait_for_input when F1=3 is	-- waiting while F1 turns 3, because we have 3 auto generated matrix 
	begin
		null;
	end wait_for_input;
	
	entry wait_for_calc when F2=4 is	-- waiting while F2 turns 4, because we have 4 threads
	begin
		null;
	end wait_for_calc;
	
	entry wait_for_calc_2 when F3=4 is	-- waiting while F3 turns 4, same reason as above, 4 threads
	begin
		null;
	end wait_for_calc_2;

	procedure SIG_INP is			-- increment the input counter, it's needed to wait_for_input entry
	begin
		F1:=F1+1;
	end SIG_INP;

	procedure SIG_CLC_1 is			-- increment the calculator counter, for the calculation MC*MK it's needed to wait_for_calc entry
	begin
		F2:=F2+1;
	end SIG_CLC_1;
	
	procedure SIG_CLC_2 is			-- increment the calculator counter, for the calculation MB*(MC*MK) it's needed to wait_for_calc_2 entry
	begin
		F3:=F3+1;
	end SIG_CLC_2;
end Control;

-- TASKS: here we have 4 tasks, or threads w/e, 1, 3, 4 tasks are for filling up elements, and calculating, 2nd task for calculating and output the result!

task T1;		-- MB
task body T1 is

begin
	put_line("Matrix inicialization");
	
	for i in 1..N loop
	  for j in 1..N loop
		MB(i,j):=1;
	  end loop;
	end loop;
	
-- increment SIG_INP
Control.SIG_INP;
-- waiting while all input done
Control.wait_for_input;

for i in 1 .. H loop
  for j in 1 .. N loop
      MCK(i,j) := 0;
      
      for k in 1 .. N loop
	MCK(i,j) := MCK(i,j) + MC(i,k)*MK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_1;
Control.wait_for_calc;

for i in 1 .. H loop
  for j in 1 .. N loop
      MA(i,j) := 0;
      
      for k in 1 .. N loop
	MA(i,j) := MA(i,j) + MB(i,k)*MCK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_2;
Control.wait_for_calc_2;

put_line("MB = ");
for i in 1 .. N loop
  for j in 1 .. N loop
	Put(integer'image(MB(i,j)));
  end loop;
  put_line(",");
end loop;

--put_line("Process T1 finished");
end T1;

-- SECOND THREAD

task T2;		-- MA
task body T2 is

begin
	put_line("Matrix calculation");
	
Control.wait_for_input;
for i in H+1 .. 2*H loop
  for j in 1 .. N loop
      MCK(i,j) := 0;
      
      for k in 1 .. N loop
	MCK(i,j) := MCK(i,j) + MC(i,k)*MK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_1;
Control.wait_for_calc;


for i in H+1 .. 2*H loop
  for j in 1 .. N loop
      MA(i,j) := 0;
      
      for k in 1 .. N loop
	MA(i,j) := MA(i,j) + MB(i,k)*MCK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_2;
Control.wait_for_calc_2;
put_line("MA = ");
for i in 1 .. N loop
  for j in 1 .. N loop
	Put(integer'image(MA(i,j)));
  end loop;
  put_line(",");
end loop;

--put_line("Process T1 finished");
end T2;

-- THIRD THREAD

task T3;		-- MC
task body T3 is

begin
	put_line("Second Matrix inicialization");
	
	for i in 1..N loop
	  for j in 1..N loop
		MK(i,j):=1;
	  end loop;
	end loop;
	
Control.SIG_INP;
Control.wait_for_input;

for i in 2*H+1 .. 3*H loop
  for j in 1 .. N loop
      MCK(i,j) := 0;
      
      for k in 1 .. N loop
	MCK(i,j) := MCK(i,j) + MC(i,k)*MK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_1;
Control.wait_for_calc;

for i in 2*H+1 .. 3*H loop
  for j in 1 .. N loop
      MA(i,j) := 0;
      
      for k in 1 .. N loop
	MA(i,j) := MA(i,j) + MB(i,k)*MCK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_2;
Control.wait_for_calc_2;

put_line("MK = ");
for i in 1 .. N loop
  for j in 1 .. N loop
	Put(integer'image(MK(i,j)));
  end loop;
  put_line(",");
end loop;

--put_line("Process T1 finished");
end T3;

task T4;		-- MK
task body T4 is

begin
	put_line("Third Matrix inicialization");
	
	for i in 1..N loop
	  for j in 1..N loop
		MC(i,j):=1;
	  end loop;
	end loop;
	
Control.SIG_INP;
Control.wait_for_input;

for i in 3*H+1 .. N loop
  for j in 1 .. N loop
      MCK(i,j) := 0;
      
      for k in 1 .. N loop
	MCK(i,j) := MCK(i,j) + MC(i,k)*MK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_1;
Control.wait_for_calc;

for i in 3*H+1 .. N loop
  for j in 1 .. N loop
      MA(i,j) := 0;
      
      for k in 1 .. N loop
	MA(i,j) := MA(i,j) + MB(i,k)*MCK(k,j);
    end loop;
  end loop;
end loop;

Control.SIG_CLC_2;
Control.wait_for_calc_2;

put_line("MC = ");
for i in 1 .. N loop
  for j in 1 .. N loop
	Put(integer'image(MC(i,j)));
  end loop;
  put_line(",");
end loop;

--put_line("Process T1 finished");
end T4;


-- body local prog

begin
put_line(" MAIN PROCEDURE STARTED");
end kursova2;

