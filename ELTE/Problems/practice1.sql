select * from dba_objects;

select owner 
from dba_objects
where (object_name = 'DBA_TABLES' and object_type = 'VIEW')
or (object_name = 'DUAL' and object_type = 'TABLE');

select *
from dba_tab_columns;

select owner, table_name, column_name
from dba_tab_columns
where column_name like 'Z%S%S';

grant select on PR01 to lkpeter;