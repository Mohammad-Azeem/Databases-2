SELECT * FROM sz1;

select * from dba_objects 
where object_name = 'SZ1'

select * 
from dba_synonyms
where synonym_name = 'SZ1'

drop table dept;

create table dept as 
select * from nikovits.dept;

drop sequence deptno_seq;

create sequence deptno_seq
increment by 10
start with 60;

drop table emp;

create table emp
as select * from nikovits.emp;

create or replace procedure insert_dept_emp is
begin
    for i in 1..3 loop
        insert into dept(deptno) values(deptno_seq.nextval);
        for j in 1..3 loop
            insert into emp(empno, deptno) values((deptno_seq.currval+j), deptno_seq.currval);
        end loop;
    end loop;
end;

call insert_dept_emp();

-- 1
select file_name, bytes
from dba_data_files;

-- 2
select tablespace_name
from dba_tablespaces;

-- 3
select df.file_name, ts.tablespace_name
from dba_tablespaces ts join dba_data_files df
on df.file_id = ts.file_id

-- 4
select tablespace_name
from dba_tablespaces
minus
select tablespace_name
from dba_data_files

-- 5
select block_size
from dba_tablespaces
where tablespace_name = 'USERS'

-- 6
select segment_type
from dba_segments
where owner = 'NIKOVITS'

select owner, segment_name, blocks
from dba_segments
where bytes = 
(select max(bytes) from dba_segments where segment_type = 'INDEX')
and segment_type = 'INDEX'

-- 7
select count(extent_id), sum(dba_extents.bytes)
from dba_data_files join dba_extents
on dba_data_files.file_id = dba_extents.file_id
where file_name like '%users02.dbf'

--8 
select count(block_id), sum(dba_free_space.bytes)
from dba_data_files join dba_free_space
on dba_data_files.file_id = dba_free_space.file_id
where file_name like '%users02.dbf'

select dba_data_files.bytes, count(block_id), dba_data_files.bytes-sum(dba_free_space.bytes)
from dba_data_files join dba_free_space
on dba_data_files.file_id = dba_free_space.file_id
where file_name like '%users02.dbf'
group by file_name,dba_data_files.bytes

-- 9
select * from(
select owner, sum(bytes) 
from dba_segments
group by owner
order by sum(bytes) desc)
where rownum = 1