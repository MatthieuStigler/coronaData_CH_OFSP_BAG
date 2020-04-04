suppressPackageStartupMessages(library(tidyverse))

################################
#'## Read doc
################################

dat_sheet5_deceased <- read_csv("data_final/sheet_5_deceased.csv", col_types = cols())
dat_sheet4_hospit <- read_csv("data_final/sheet_4_hospitalised.csv", col_types = cols())

################################
#'## Barplot by age and gender
################################

## long version
dat_sheet5_deceased_l <- dat_sheet5_deceased %>% 
  gather(category, n_cases, ends_with("deceased")) %>% 
  mutate(category = str_remove(category, "_deceased") %>% 
           str_to_title()) 

last_date <- max(dat_sheet5_deceased_l$report_date) %>% 
  format("%d %B %Y")

## plot
pl_age <- dat_sheet5_deceased_l %>% 
  filter(category!="Total")%>% 
  filter(report_date == max(report_date)) %>% 
  rename(Gender=category) %>% 
  ggplot(aes(x = age_class, y = n_cases, fill=Gender)) + 
  geom_col(position = "dodge") +
  ggtitle(paste0("Number of deaths by age category (", last_date, ")")) +
  xlab("Age class") + ylab("Number of cases") +
  labs(caption = "Source: Federal Office of Public Health BAG/OFSP") +
  theme(plot.caption = element_text(hjust = 0))

pl_age

################################
#'## Evolution
################################

gg_byDate_age <- function(df, variable) {
  df %>% 
    ggplot(aes(x = report_date, y = {{variable}}, color=age_class)) + 
    geom_line(lwd=1.3, alpha = 0.8) +
    geom_point(size = 2) +
    xlab("Date") +
    labs(color = "Age class")
}

pl_deceased_time_colorAge <-  dat_sheet5_deceased_l %>% 
  filter(category=="Total") %>% 
  gg_byDate_age(n_cases)+
  ylab("Number of cases") +
  ggtitle("Deceased cases over time, by age")

pl_deceased_time_colorAge

################################
#'## Hospitalised
################################

pl_hospit_time_colorAge <- dat_sheet4_hospit %>% 
  gg_byDate_age(total_hospitalised)+
  ylab("Number of cases") +
  ggtitle("Hospitalised cases over time, by age")

pl_hospit_time_colorAge

## deceased by hospit
dat_sheet4_hospit %>% 
  select(age_class, report_date, total_hospitalised) %>% 
  inner_join(dat_sheet5_deceased %>% 
               select(age_class, report_date, total_deceased), 
             by = c("age_class", "report_date")) %>% 
  mutate(deceased_by_hospit = 100*total_deceased/total_hospitalised) %>% 
  gg_byDate_age(deceased_by_hospit)+
  ylab("Percentage deceases") +
  ggtitle("deceased/hospitalised over time, by age")

################################
#'## Export
################################

ggsave(pl_age, filename="output/figures/deaths_by_age.png", width = 8, height = 6)
ggsave(pl_deceased_time_colorAge, filename="output/figures/deceased_over_time_by_age.png", width = 8, height = 6)
ggsave(pl_hospit_time_colorAge, filename="output/figures/hospitalised_over_time_by_age.png", width = 8, height = 6)

