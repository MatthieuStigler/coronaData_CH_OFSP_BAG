library(tidyverse)     

################################
#'## Read doc
################################

dat_deceased_age <- read_csv("data_final/sheet_5_deceased_by_age.csv")

################################
#'## Barplot by age and gender
################################

## long version
dat_deceased_age_l <- dat_deceased_age %>% 
  gather(category, n_cases, ends_with("deceased")) %>% 
  mutate(category = str_remove(category, "_deceased") %>% 
           str_to_title()) 

last_date <- max(dat_deceased_age_l$date) %>% 
  format("%d %B %Y")

## plot
pl_age <- dat_deceased_age_l %>% 
  filter(category!="Total")%>% 
  filter(date == max(date)) %>% 
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

pl_time_age <- dat_deceased_age_l %>% 
  filter(category=="Total") %>% 
  ggplot(aes(x = date, y = n_cases, color=age_class)) + 
  geom_line(lwd=1.5) +
  geom_point() +
  xlab("Date") + ylab("Number of cases") +
  labs(color = "Age class") +
  ggtitle("Deceased cases over time, by age")

pl_time_age

################################
#'## Export
################################

ggsave(pl_age, filename="output/figures/deaths_by_age.png", width = 8, height = 6)
ggsave(pl_time_age, filename="output/figures/deaths_over_time_by_age.png", width = 8, height = 6)
