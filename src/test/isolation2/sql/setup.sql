-- Helper function, to call either __gp_aoseg_name, or gp_aocsseg_name,
-- dependingwhether the table is row- or column-oriented. This allows us to
-- run the same test queries on both.
--
-- The Python utility that runs this doesn't know about dollar-quoting,
-- and thinks that a ';' at end of line ends the command. The /* in func */
-- comments at the end of each line thwarts that.
CREATE OR REPLACE FUNCTION gp_ao_or_aocs_seg_name(rel text,
  segno OUT integer,
  tupcount OUT bigint,
  modcount OUT bigint,
  formatversion OUT smallint,
  state OUT smallint)
RETURNS SETOF record as $$
declare
  relstorage_var char;	/* in func */
begin	/* in func */
  select relstorage into relstorage_var from pg_class where oid = rel::regclass; /* in func */
  if relstorage_var = 'c' then	/* in func */
    for segno, tupcount, modcount, formatversion, state in SELECT DISTINCT x.segno, x.tupcount, x.modcount, x.formatversion, x.state FROM gp_toolkit.__gp_aocsseg_name(rel) x loop	/* in func */
      return next;	/* in func */
    end loop;	/* in func */
  else	/* in func */
    for segno, tupcount, modcount, formatversion, state in SELECT x.segno, x.tupcount, x.modcount, x.formatversion, x.state FROM gp_toolkit.__gp_aoseg_name(rel) x loop	/* in func */
      return next;	/* in func */
    end loop;	/* in func */
  end if;	/* in func */
end;	/* in func */
$$ LANGUAGE plpgsql;
