# ------------------------------------------------
# plotting with ggplot2
# ------------------------------------------------
# install.packages('ggplot2')
library('ggplot2')
data(mpg)

# layers 1-2-3
ggplot(data = mpg, aes(x = displ, y = hwy)) + 
  geom_point()


ggplot(data = mpg, aes(x = displ, y = hwy, shape = factor(cyl))) + 
  geom_point()

# add layer 4: facets
# add factor for class
ggplot(data = mpg, aes(x = displ, y = hwy, color = factor(cyl))) + 
  geom_point() +
  facet_wrap(~ year)

# layer 5 statistics
ggplot(data = mpg, aes(x = cyl, y = hwy)) + 
  geom_point() + 
  stat_summary(fun = "median", color = "red", size = 1) 

# layer 6 coordinates
# layer 5 statistics
ggplot(data = mpg, aes(x = cyl, y = hwy)) + 
  geom_point() + 
  stat_summary(fun = "median", color = "red", size = 1) +
  coord_flip()


# layer 7 themes
ggplot(data = mpg, aes(x = cyl, y = hwy)) + 
  geom_point() + 
  stat_summary(fun = "median", color = "red", size = 1) +
  theme_bw()


# add axes titles and change font size 
ggplot(data = mpg, aes(x = cyl, y = hwy)) + 
  geom_point() + 
  stat_summary(fun = "median", color = "red", size = 1) +
  theme_bw(base_size = 16) + 
  labs(x = "highway", y = "cylinder")


# one way densities
ggplot(data = mpg, aes(x = hwy)) + geom_histogram()


# ------------------------------------------------
# Bar charts 
# ------------------------------------------------
LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS")

ggplot(LFS_2019) + 
  geom_bar(aes(x = DISTRICT_STR, 
               fill = factor(any_bank_account),
               weight = Weight)) +
  coord_flip() +
  xlab("District") +
  ylab("Households") + 
  theme_minimal(base_size = 14) +
  theme(legend.position="bottom")


ggplot(LFS_2019, aes(x = DISTRICT_STR, 
                     fill = factor(any_bank_account),
                      weight = Weight)) + 
  geom_bar(position = "fill") +
  coord_flip() +
  xlab("District") +
  ylab("% of Households in District") + 
  theme_minimal(base_size = 14) +
  theme(legend.position="bottom") +
  labs(fill = "Has Bank Account")



ggplot(LFS_2019, aes(x = DISTRICT_STR, fill = factor(no_bank_no_money),
                      weight = Weight)) + 
  geom_bar(position = "fill") +
  coord_flip() +
  xlab("District") +
  ylab("% of Households in District") + 
  theme_minimal(base_size = 14) +
  theme(legend.position="bottom") +
  labs(fill = "Primary reason for not having a bank \n account because not enough money")



# Interactive plots using plotly

p <- 
  ggplot(LFS_2019, aes(x = DISTRICT_STR, fill = factor(any_bank_account),
                       weight = Weight)) + 
  geom_bar(position = "fill") +
  coord_flip() +
  xlab("District") +
  ylab("% of Households in District") + 
  theme_minimal(base_size = 14) +
  theme(legend.position="bottom") +
  labs(fill = "Has Bank Account")

plot(p)

library('plotly')
ggplotly(p)

# save plot using ggsave
ggsave("figures/has_bank_barplot.png", width = 6, height = 4.5)

# ------------------------------------------------
# Lab Exercises
# ------------------------------------------------

# 1. Produce a bar chart of the fraction of households in each district 
#    that has borrowed formally. 

# 2. Save the plot using the the function ggsave()





