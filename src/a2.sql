--get permissions:
--ask about if q1 ir right and whats wrong with q3.
create or replace function func_permissions_okay return varchar is
v_file varchar2(30):='UTL_FILE';
v_string varchar2(40):='EXECUTE';
is_true varchar2(1) ;
aCount number;
begin
select count(table_name) into aCount from  USER_TAB_PRIVS where TABLE_NAMe=v_file and  PRIVILEGE=v_string;
if aCount>0 then
  is_true:='Y';
else
  is_true:='N';
end if;

return is_true;
end;
/

create or replace trigger t_bin_pl
before insert on payroll_load
for each row
DECLARE

v_payroll number := 4045;
v_accounts number := 2050;
begin
  insert into new_transactions values(wkis_seq.NEXTVAL,:new.payroll_date,'',v_accounts,'C',:new.amount);
  insert into new_transactions values(wkis_seq.currVAL,:new.payroll_date,'',v_payroll,'D',:new.amount);
  :new.status:='G';
exception
when others then
  :new.status:='B';
end;
/
SET SERVEROUTPUT ON;

create or replace procedure proc_month_end is

cursor x is select * from account where (Account_type_code = 'RE' or Account_type_code='EX') and ACCOUNT_BALANCE !=0;
temp1 varchar(2) := 'RE';

BEGIN
for y in x loop
  if y.account_type_code = temp1 then
    insert into new_transactions values(wkis_seq.NEXTVAL,sysdate,'',5555,'C',y.account_balance);
    insert into new_transactions values(wkis_seq.CURRVAL,sysdate,'',y.account_no,'D',y.account_balance);
  else
    insert into new_transactions values(wkis_seq.NEXTVAL,sysdate,'',5555,'D',y.account_balance);
    insert into new_transactions values(wkis_seq.currVAL,sysdate,'',y.account_no,'C',y.account_balance);    
  end if;

end loop;

    
END;
/

create or replace procedure proc_export_csv(path varchar2,fileName varchar2) is
fle  UTL_FILE.FILE_TYPE;
cursor x is select * from new_transactions;
begin
	fle:=utl_file.fopen(path,fileName,'w');
	for y in x loop
		utl_file.put_line(fle,y.TRANSACTION_no ||','||y.TRANSACTION_date||','||y.description||','||
							y.account_no||','||y.TRANSACTION_type||','||y.TRANSACTION_amount);
	end loop;
utl_file.fclose(fle);
end;
/