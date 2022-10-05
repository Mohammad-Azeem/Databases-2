--1
select blocks
from dba_segments
where owner = 'NIKOVITS' and segment_name = 'CIKK'

--2
create or replace function calc_empty_blocks return integer
is
    reserved_blocks integer;
    filled_blocks integer;
    empty_blocks integer;
begin
    select blocks into reserved_blocks
    from dba_segments
    where owner = 'NIKOVITS' and segment_name = 'CIKK';

    select count(distinct DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid))
    into filled_blocks
    from nikovits.cikk;

    empty_blocks := reserved_blocks - filled_blocks;
    return empty_blocks;
end;

select calc_empty_blocks() from dual;

-- 3
select DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid), 
count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))
from nikovits.cikk
group by DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid);

-- 4
create or replace procedure get_file_and_segment is
    fno integer;
    bno integer;
    ono integer;
    fname varchar(100);
    sname varchar(100);
begin
    select DBMS_ROWID.ROWID_RELATIVE_FNO(rowid),
    DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid),
    DBMS_ROWID.ROWID_OBJECT(rowid)
    into fno, bno, ono
    from nikovits.eladasok
    where szla_szam = 100;
    
    select file_name into fname
    from dba_data_files
    where relative_fno = fno;
    
    select segment_name into sname
    from dba_segments
    where relative_fno = fno 
    and bno between header_block and header_block + blocks;
    
    dbms_output.put_line(fname || ' - ' || TO_CHAR(bno) || ' - ' || sname);
end;

set serveroutput on

call get_file_and_segment();

-- 5

create or replace procedure num_of_rows is
    c integer;
begin
    for rec in (select file_id, block_id, blocks
                from dba_extents
                where owner = 'NIKOVITS' and segment_name = 'TABLA_123')
    loop
        for bno in rec.block_id..rec.block_id + rec.blocks - 1
        loop
            select
            count(DBMS_ROWID.ROWID_ROW_NUMBER(rowid))
            into c
            from nikovits.tabla_123
            where DBMS_ROWID.ROWID_BLOCK_NUMBER(rowid) = bno;
            dbms_output.put_line(TO_CHAR(rec.file_id) ||'; '||TO_CHAR(bno) || ' -> ' || TO_CHAR(c));
        end loop;
    end loop;
end;

execute check_plsql('num_of_rows()');