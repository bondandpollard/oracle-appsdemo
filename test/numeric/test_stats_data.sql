select p.stats_project_id
  ,p.description
  ,s.stats_data_id
  ,s.stats_project_id data_project
  ,s.description
  ,s.stats_value
from stats_project p
full join stats_data s on s.stats_project_id = p.stats_project_id
order by p.stats_project_id;