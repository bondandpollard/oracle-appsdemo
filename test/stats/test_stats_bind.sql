-- Bind variables
select * from stats_project
where stats_project_id = :p_project_id or :p_project_id IS NULL;