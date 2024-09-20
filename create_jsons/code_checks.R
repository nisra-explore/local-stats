library("styler")

style_file("census_data_loop.R", scope = "line_breaks")
style_file("create_JSONs.R", scope = "line_breaks")
style_file("read_all_dataportal_tables_in.R", scope = "line_breaks")
style_file("data_portal_tables_loop.R", scope = "line_breaks")
style_file("read_and_process_census_data.R", scope = "line_breaks")


library("lintr")
lintr::lint("census_data_loop.R")
lintr::lint("create_JSONs.R")
lintr::lint("read_all_dataportal_tables_in.R")
lintr::lint("data_portal_tables_loop.R")
lintr::lint("read_and_process_census_data.R")