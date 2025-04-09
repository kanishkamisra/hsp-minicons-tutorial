library(tidyverse)
library(lmerTest)
library(scales)

models <- c("opt-125m", "opt-350m", "opt-1.3b", "opt-2.7b", "opt-6.7b", 
            "pythia-70m", "pythia-160m", "pythia-410m", "pythia-1b", "pythia-1.4b", 
            "pythia-2.8b", "pythia-6.9b", "pythia-12b",
            "rwkv4-169m", "rwkv4-430m", "rwkv4-1b", "rwkv4-3b", "rwkv4-7b",
            "mamba-130m", "mamba-370m", "mamba-790m", "mamba-1.4b", "mamba-2.8b")
model_family <- c(rep("OPT", 5), rep("Pythia", 8), rep("RWKV", 5), rep("Mamba", 5))

model_meta <- tibble(
  model = factor(models, levels = models),
  family = factor(model_family, levels = c("OPT", "Pythia", "RWKV", "Mamba"))
)

fk_stimuli <- read_csv("data/fk1999-final.csv")

results <- fs::dir_ls("results/fk1999/", regexp = "*.csv") %>%
  map_df(read_csv, .id = "model") %>%
  mutate(
    model = str_extract(model, "(?<=results/fk1999/)(.*)(?=\\.csv)"),
    model = str_remove(model, "facebook__|EleutherAI__|RWKV__|state-spaces__"),
    model = str_remove(model, "-deduped|-pile|-hf"),
    model = str_replace(model, "-4-", "4-"),
    model = str_replace(model, "1b5", "1b"),
    model = factor(model, levels = models)
  ) %>%
  inner_join(fk_stimuli %>% select(item, cloze_expected, constraint))


model_meta <- model_meta %>%
  inner_join(results %>% distinct(model, parameters))

# results %>%
#   group_by(model, constraint) %>%
#   summarize(
#     
#   )
#   ggplot(aes(constraint, entropy)) +
#   geom_boxplot() +
#   facet_wrap(~model)

results %>%
  group_by(model, constraint) %>%
  summarize(
    # cl = 1.96 * plotrix::std.error(exp(expected_logprob)),
    # entropy = mean(exp(expected_logprob))
    cl = 1.96 * plotrix::std.error(entropy),
    entropy = mean(entropy)
  ) %>%
  inner_join(model_meta) %>%
  ggplot(aes(parameters, entropy, color = constraint, fill = constraint, group=interaction(constraint, family))) +
  # geom_point(size = 2.5, position = position_dodge(0.5)) +
  # geom_linerange(aes(ymin = entropy-cl, ymax = entropy+cl), position = position_dodge(0.5)) +
  geom_point(size = 2.5) +
  geom_line(linewidth=0.8) +
  # # geom_ribbon(aes(ymin = entropy-cl, ymax = entropy+cl), alpha = 0.2, color=NA) +
  geom_linerange(aes(ymin = entropy-cl, ymax = entropy+cl)) +
  scale_x_log10() +
  facet_wrap(~family, scales = "free_x")
  # geom_point(size = 2.5, position = position_dodge(0.5)) +
  # geom_linerange(aes(ymin = entropy-cl, ymax = entropy+cl), position = position_dodge(0.5))


full <- lmer(-within_logprob ~ constraint + (1 + constraint | model), data = results, REML = FALSE)
reduced <- lmer(-within_logprob ~ (1 + constraint | model), data = results, REML = FALSE)
anova(full, reduced)

summary(full)

results %>% 
  filter(within_logprob > -15) %>%
  ggplot(aes(log(cloze_expected), -within_logprob)) +
  geom_point() +
  geom_smooth(method="lm") +
  facet_wrap(~model)

full <- lm(-within_logprob ~ constraint, data = results %>% filter(model == "pythia-410m"))
summary(full)

results %>%
  pivot_longer(expected_logprob:between_logprob, names_to = "completion", values_to = "logprob") %>%
  mutate(
    completion = str_remove(completion, "_logprob"),
    logprob = -1 * logprob,
    completion = factor(completion, levels = c("expected", "within", "between"))
  ) %>%
  group_by(model, constraint, completion) %>%
  summarize(
    ste = 1.96 * plotrix::std.error(logprob),
    logprob = mean(logprob)
  ) %>%
  ggplot(aes(constraint, logprob, color = completion)) +
  geom_point(size = 2.5) +
  geom_linerange(aes(ymin=logprob-ste, ymax = logprob+ste)) +
  facet_wrap(~model) +
  labs(
    y = "Surprisal",
    x = "Constraint"
  )

## conditions

results %>%
  group_by(model, constraint) %>%
  summarize(
    accuracy = mean((expected_logprob > within_logprob) & (within_logprob > between_logprob))
    # accuracy = mean((expected_logprob > within_logprob))
    # accuracy = mean(within_logprob > between_logprob)
  ) %>%
  ungroup() %>%
  inner_join(model_meta) %>%
  ggplot(aes(model, accuracy, color = constraint, group = interaction(family, constraint))) +
  geom_line()


results %>%
  group_by(model) %>%
  summarize(
    overall = mean((expected_logprob > within_logprob) & (within_logprob > between_logprob))
    # accuracy = mean((expected_logprob > within_logprob))
    # accuracy = mean(within_logprob > between_logprob)
  ) %>%
  ungroup() %>%
  inner_join(model_meta) %>%
  ggplot(aes(parameters, overall, color = family, shape=family, fill=family)) +
  geom_point(size=3, alpha = 0.9) +
  geom_hline(yintercept = 0.33, linetype="dashed") +
  scale_x_log10(labels = label_log(digits = 2)) +
  scale_y_continuous(limits = c(0.2,0.8), labels = percent_format()) +
  scale_color_brewer(palette = "Dark2", aesthetics = c("color", "fill")) +
  scale_shape_manual(values=c(21, 22, 23, 24)) +
  theme_bw(base_size=18, base_family = "Times") +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    legend.position = "top"
  ) +
  labs(
    x = "Parameters",
    y = "Expected Pattern Observed",
    color = "Family",
    fill = "Family",
    shape = "Family",
  ) +
  annotation_logticks()

# 554 497

results %>%
  pivot_longer(expected_logprob:between_logprob, names_to = "completion", values_to = "logprob") %>%
  mutate(
    surprisal = -logprob,
    completion = str_remove(completion, "_logprob"),
    completion = factor(completion, levels = c("expected", "within", "between"))
  ) %>%
  group_by(model) %>%
  mutate(surprisal = scale(surprisal)) %>%
  ungroup() %>%
  group_by(model, completion, constraint) %>%
  summarize(
    n = n(),
    sd = sd(surprisal),
    conf = qt(1 - (0.05/2), n - 1) * sd/sqrt(n),
    surprisal = mean(surprisal)
  ) %>%
  ggplot(aes(completion, surprisal, color = constraint)) +
  # geom_point() +
  # geom_linerange(aes(ymin = surprisal-conf, ymax=surprisal+conf)) +
  geom_point(position = position_dodge(0.5)) +
  geom_linerange(aes(ymin = surprisal-conf, ymax=surprisal+conf), position=position_dodge(0.5)) +
  facet_wrap(~model) +
  theme_bw(base_size=18, base_family = "Times") +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(color = "black"),
    legend.position = "top"
  ) 


results %>%
  group_by(model) %>%
  mutate(
    model_constraint = case_when(
      entropy >= median(entropy) ~ "low",
      # expected_logprob <= median(expected_logprob) ~ "low",
      TRUE ~ "high"
    )
  ) %>%
  ungroup() %>%
  pivot_longer(expected_logprob:between_logprob, names_to = "completion", values_to = "logprob") %>%
  mutate(
    completion = str_remove(completion, "_logprob"),
    logprob = -1 * logprob,
    completion = factor(completion, levels = c("expected", "within", "between"))
  ) %>%
  group_by(model, model_constraint, completion) %>%
  summarize(
    ste = 1.96 * plotrix::std.error(logprob),
    logprob = mean(logprob)
  ) %>%
  ggplot(aes(model_constraint, logprob, color = completion)) +
  geom_point(size = 2.5) +
  geom_linerange(aes(ymin=logprob-ste, ymax = logprob+ste)) +
  facet_wrap(~model) +
  labs(
    y = "Surprisal",
    x = "Constraint"
  )


results %>%
  group_by(model) %>%
  mutate(
    model_constraint = case_when(
      expected_logprob <= median(expected_logprob) ~ "low",
      TRUE ~ "high"
    )
  ) %>%
  ungroup() %>%
  pivot_longer(expected_logprob:between_logprob, names_to = "completion", values_to = "logprob") %>%
  mutate(
    completion = str_remove(completion, "_logprob"),
    logprob = -1 * logprob,
    completion = factor(completion, levels = c("expected", "within", "between"))
  ) %>%
  ggplot(aes(entropy, logprob, color = completion)) +
  geom_point(size = 2, alpha = 0.4) +
  # geom_linerange(aes(ymin=logprob-ste, ymax = logprob+ste)) +
  facet_wrap(~model) +
  labs(
    y = "Surprisal",
    x = "Constraint"
  )

# ---

results %>%
  group_by(model) %>%
  mutate(
    model_constraint = case_when(
      expected_logprob <= median(expected_logprob) ~ "low",
      TRUE ~ "high"
    )
  ) %>%
  ungroup() %>%
  pivot_longer(expected_logprob:between_logprob, names_to = "completion", values_to = "logprob") %>%
  mutate(
    completion = str_remove(completion, "_logprob"),
    logprob = -1 * logprob,
    completion = factor(completion, levels = c("expected", "within", "between"))
  ) %>%
  group_by(model) %>%
  mutate(entropy_bin = ntile(cloze_expected, 10)) %>%
  ungroup() %>%
  group_by(model, entropy_bin, completion) %>%
  summarize(
    ste = 1.96 * plotrix::std.error(logprob),
    logprob = mean(logprob)
  ) %>%
  ggplot(aes(entropy_bin, logprob, color = completion)) +
  # geom_point(size = 2, alpha = 0.4) +
  # geom_linerange(aes(ymin=logprob-ste, ymax = logprob+ste)) +
  geom_line() +
  facet_wrap(~model) +
  labs(
    y = "Surprisal",
    x = "Constraint"
  )


# -- in terms of differences

results %>%
  group_by(model) %>%
  mutate(
    model_constraint = case_when(
      # expected_logprob <= median(expected_logprob) ~ "low",
      entropy >= median(entropy) ~ "low",
      TRUE ~ "high"
    )
  ) %>%
  ungroup() %>%
  mutate(
    expected_within = within_logprob - expected_logprob,
    expected_between = expected_logprob - between_logprob,
    within_between = between_logprob - within_logprob
  ) %>%
  select(-expected_logprob, -within_logprob, -between_logprob) %>%
  pivot_longer(expected_within:within_between, names_to = "completion", values_to = "logprob") %>%
  mutate(
    completion = str_remove(completion, "_logprob"),
    logprob = -1 * logprob,
    completion = factor(completion, levels = c("expected_within", "expected_between", "within_between"))
  ) %>%
  # group_by(model) %>%
  # mutate(entropy_bin = ntile(entropy, 10)) %>%
  # ungroup() %>% View()
  group_by(model, constraint, completion) %>%
  summarize(
    ste = 1.96 * plotrix::std.error(logprob),
    logprob = mean(logprob)
  ) %>%
  ggplot(aes(constraint, logprob, color = completion)) +
  # geom_line() +
  geom_point(size = 2, alpha = 0.4) +
  # geom_linerange(aes(ymin=logprob-ste, ymax = logprob+ste)) +
  facet_wrap(~model) +
  labs(
    y = "Surprisal",
    x = "Constraint"
  )

