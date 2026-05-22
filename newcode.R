# ============================================================
# Social Media & Mental Health — Full Multivariate Analysis
# Dataset : smmh.csv (Kaggle, 481 obs, 21 variables)
# Methods  : PCA (FactoMineR) + K-means + HAC (Ward)
# ============================================================

# ============================================================
# 0. PACKAGES
# ============================================================
packages <- c("tidyverse", "FactoMineR", "factoextra",
              "cluster", "ggplot2", "corrplot", "knitr", "gridExtra")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])
invisible(lapply(packages, library, character.only = TRUE))


# ============================================================
# 1. LOAD DATA
# ============================================================
df_raw <- read_csv("smmh.csv", show_col_types = FALSE)
cat("Raw dimensions:", dim(df_raw), "\n")


# ============================================================
# 2. PRE-PROCESSING
# ============================================================

# --- 2a. Rename columns ---
df <- df_raw %>%
  rename(
    age                 = `1. What is your age?`,
    gender              = `2. Gender`,
    relationship_status = `3. Relationship Status`,
    occupation          = `4. Occupation Status`,
    platforms_used      = `7. What social media platforms do you commonly use?`,
    daily_usage_hours   = `8. What is the average time you spend on social media every day?`,
    no_purpose          = `9. How often do you find yourself using Social media without a specific purpose?`,
    distracted          = `10. How often do you get distracted by Social media when you are busy doing something?`,
    restless            = `11. Do you feel restless if you haven't used Social media in a while?`,
    easily_distracted   = `12. On a scale of 1 to 5, how easily distracted are you?`,
    worries             = `13. On a scale of 1 to 5, how much are you bothered by worries?`,
    concentration       = `14. Do you find it difficult to concentrate on things?`,
    compare_self        = `15. On a scale of 1-5, how often do you compare yourself to other successful people through the use of social media?`,
    comparison_feeling  = `16. Following the previous question, how do you feel about these comparisons, generally speaking?`,
    seek_validation     = `17. How often do you look to seek validation from features of social media?`,
    depression_freq     = `18. How often do you feel depressed or down?`,
    interest_fluct      = `19. On a scale of 1 to 5, how frequently does your interest in daily activities fluctuate?`,
    sleep_issues        = `20. On a scale of 1 to 5, how often do you face issues regarding sleep?`
  )

# --- 2b. Ordinal encoding of daily usage ---
usage_levels <- c("Less than an Hour", "Between 1 and 2 hours",
                  "Between 2 and 3 hours", "Between 3 and 4 hours",
                  "Between 4 and 5 hours", "More than 5 hours")
df <- df %>%
  mutate(daily_usage_ord = as.integer(factor(daily_usage_hours,
                                             levels = usage_levels,
                                             ordered = TRUE)))

# --- 2c. Select quantitative variables ---
quant_vars <- c("daily_usage_ord", "no_purpose", "distracted", "restless",
                "easily_distracted", "worries", "concentration",
                "compare_self", "comparison_feeling", "seek_validation",
                "depression_freq", "interest_fluct", "sleep_issues")

df_clean <- df %>%
  select(all_of(quant_vars), gender, age) %>%
  drop_na()
cat("Rows after dropping NAs:", nrow(df_clean), "\n")

# --- 2d. Outlier detection (Z-score method, |z| > 3) ---
# NOTE: No extreme outliers found in this dataset (all |z| <= 3),
# but we inspect boxplots for visual confirmation.
z_scores <- df_clean %>%
  select(all_of(quant_vars)) %>%
  scale()
outlier_rows <- which(apply(abs(z_scores) > 3, 1, any))
cat("Outlier rows (|z| > 3):", length(outlier_rows), "\n")

# Boxplot for visual outlier inspection
df_clean %>%
  select(all_of(quant_vars)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(fill = "#B5D4F4", color = "#185FA5", outlier.shape = 21,
               outlier.fill = "#E24B4A", outlier.color = "#A32D2D") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Boxplot — Outlier Detection per Variable",
       x = "", y = "Value")

# --- 2e. Standardize ---
df_scaled <- df_clean %>%
  select(all_of(quant_vars)) %>%
  scale() %>%
  as.data.frame()


# ============================================================
# 3. PCA
# ============================================================
pca_res <- PCA(df_scaled, graph = FALSE)

# Scree plot
fviz_eig(pca_res, addlabels = TRUE, ylim = c(0, 45),
         title = "Scree Plot — Variance Explained by Each Principal Component")

# Cumulative variance and PC selection
cum_var <- cumsum(pca_res$eig[, 2])
cat("\nCumulative variance explained:\n")
print(round(cum_var, 1))

# Retain PCs explaining >= 70% variance
# RESULT: 6 PCs needed (cumulative 75.6% at PC6; 69.9% at PC5)
# We retain 6 PCs to cross the 70% threshold.
n_pcs <- which(cum_var >= 70)[1]
n_pcs <- min(n_pcs, ncol(pca_res$var$coord))
cat("Retaining", n_pcs, "principal components (>=70% cumulative variance)\n")

# Variable contributions biplot
fviz_pca_var(pca_res,
             col.var   = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel     = TRUE,
             title     = "PCA — Variable Contributions (PC1 vs PC2)")

# Loading matrix (coordinates = correlations with PCs)
loadings <- pca_res$var$coord[, 1:n_pcs]
cat("\nLoading matrix (first", n_pcs, "PCs):\n")
print(round(loadings, 3))

# Interpretation of axes:
# PC1 (38.4%): general mental health burden — all variables load positively.
#              High scores = high distraction, depression, worries, sleep issues.
#              Represents overall social-media-related psychological load.
# PC2 (9.3%):  social comparison vs usage intensity dimension.
#              compare_self & seek_validation load positively; daily_usage & no_purpose load negatively.
#              Distinguishes passive heavy users from active social comparers.

# Extract PC scores
pc_scores <- as.data.frame(pca_res$ind$coord[, 1:n_pcs])


# ============================================================
# 4. DETERMINE OPTIMAL k
# ============================================================
set.seed(42)

# Elbow method (WSS)
fviz_nbclust(pc_scores, kmeans, method = "wss", k.max = 10,
             linecolor = "#185FA5") +
  labs(title = "Elbow Method — Within-cluster Sum of Squares")

# Silhouette method
# RESULT: silhouette peaks at k=2 (0.280), then drops steadily.
# k=3 chosen (0.200) for richer, more interpretable profiling while
# remaining close to the statistical optimum.
fviz_nbclust(pc_scores, kmeans, method = "silhouette", k.max = 10,
             linecolor = "#D7191C") +
  labs(title = "Silhouette Method — Average Silhouette Width")

# Gap statistic
gap_stat <- clusGap(pc_scores, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
fviz_gap_stat(gap_stat) + ggtitle("Gap Statistic")

# >>> Justified choice: k = 3 <<<
# Silhouette peaks at k=2; however k=3 yields three meaningfully distinct
# profiles (low-risk older users / moderate / high-impact young users),
# confirmed by 87.3% agreement with hierarchical clustering and
# highly significant ANOVA across all mental health variables (p < 0.0001).
k <- 3


# ============================================================
# 5. K-MEANS CLUSTERING
# ============================================================
set.seed(42)
km_res <- kmeans(pc_scores, centers = k, nstart = 50, iter.max = 300)

cat("\nK-means cluster sizes:\n")
print(table(km_res$cluster))

df_clean$cluster <- factor(km_res$cluster)


# ============================================================
# 6. HIERARCHICAL AGGLOMERATIVE CLUSTERING (validation)
# ============================================================

# Distance matrix + Ward's linkage
dist_matrix <- dist(pc_scores, method = "euclidean")
hc_res      <- hclust(dist_matrix, method = "ward.D2")

# Dendrogram
plot(hc_res,
     main   = "Hierarchical Clustering Dendrogram (Ward's Method)",
     xlab   = "Observations",
     ylab   = "Height (inertia)",
     labels = FALSE,
     hang   = -1)
rect.hclust(hc_res, k = k, border = c("#E41A1C", "#377EB8", "#4DAF4A"))

# Cut tree
hc_clusters <- cutree(hc_res, k = k)
df_clean$hc_cluster <- factor(hc_clusters)

cat("\nHierarchical cluster sizes:\n")
print(table(hc_clusters))

# Agreement between K-means and HAC
agreement_table <- table(KMeans = df_clean$cluster,
                         Hierarchical = df_clean$hc_cluster)
cat("\nAgreement table K-means vs Hierarchical:\n")
print(agreement_table)
agreement_rate <- sum(apply(agreement_table, 1, max)) / nrow(df_clean) * 100
cat(sprintf("Label-matched agreement rate: %.1f%%\n", agreement_rate))

# Silhouette scores
sil_km <- silhouette(km_res$cluster, dist_matrix)
sil_hc <- silhouette(hc_clusters,    dist_matrix)
cat("K-means avg silhouette width:      ", round(mean(sil_km[, 3]), 3), "\n")
cat("Hierarchical avg silhouette width: ", round(mean(sil_hc[, 3]), 3), "\n")

# Silhouette plots
fviz_silhouette(sil_km, palette = "Set1", ggtheme = theme_minimal(),
                title = "Silhouette Plot — K-means (k=3)")
fviz_silhouette(sil_hc, palette = "Set1", ggtheme = theme_minimal(),
                title = "Silhouette Plot — Hierarchical Clustering (k=3)")


# ============================================================
# 7. VISUALIZE CLUSTERS IN PCA SPACE (Step 5 — combined)
# ============================================================

# K-means in PCA space
fviz_cluster(km_res, data = pc_scores,
             palette        = c("#E41A1C", "#377EB8", "#4DAF4A"),
             geom           = "point",
             ellipse.type   = "convex",
             ggtheme        = theme_minimal(),
             main           = "K-means Clusters in PCA Space (PC1 vs PC2)")

# HAC in PCA space
fviz_cluster(list(data = pc_scores, cluster = hc_clusters),
             palette        = c("#E41A1C", "#377EB8", "#4DAF4A"),
             geom           = "point",
             ellipse.type   = "convex",
             ggtheme        = theme_minimal(),
             main           = "Hierarchical Clusters in PCA Space (PC1 vs PC2)")

# Relationship between PC1 and cluster membership:
# Cluster 3 (low-risk) sits at low PC1 values (low overall burden).
# Cluster 2 (high-impact) sits at high PC1 values.
# Cluster 1 (moderate) occupies the middle range.
# This confirms PC1 directly drives the segmentation.


# ============================================================
# 8. CLUSTER PROFILES — named typologies
# ============================================================
cluster_profile <- df_clean %>%
  group_by(cluster) %>%
  summarise(across(all_of(quant_vars), mean, .names = "{.col}"),
            age = mean(age),
            n   = n()) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2)))

cat("\nCluster profiles (variable means):\n")
print(knitr::kable(cluster_profile,
                   caption = "Cluster Profiles — Variable Means"))

# Profile heatmap
profile_long <- cluster_profile %>%
  select(-n, -age) %>%
  pivot_longer(cols = all_of(quant_vars), names_to = "variable", values_to = "mean_val")

ggplot(profile_long, aes(x = variable, y = cluster, fill = mean_val)) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#D6604D",
                       midpoint = 3, name = "Mean") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Cluster Profiles — Mean Score per Variable",
       x = "", y = "Cluster")

# Named profiles (based on variable means):
# Cluster 3 — "Resilient Low-Users" (n≈79, avg age 33.9)
#   All scores low (depression ~1.7, sleep ~1.9, usage ~2.5h/day).
#   Older adults with healthy relationship with social media.
#
# Cluster 1 — "Moderate Passive Users" (n≈197, avg age 25.8)
#   Mid-range scores; some distraction and mild worries but functional.
#   Young adults with average engagement.
#
# Cluster 2 — "High-Impact Heavy Users" (n≈205, avg age 23.5)
#   All scores high (depression ~4.1, sleep ~3.9, worries ~4.3, usage ~4.75).
#   Young users showing clear signs of social-media-related mental health strain.


# ============================================================
# 9. DEMOGRAPHIC BREAKDOWN PER CLUSTER
# ============================================================

# Gender distribution
gender_dist <- df_clean %>%
  count(cluster, gender) %>%
  group_by(cluster) %>%
  mutate(pct = round(100 * n / sum(n), 1))

ggplot(gender_dist, aes(x = cluster, y = pct, fill = gender)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal() +
  labs(title = "Gender Distribution by Cluster",
       x = "Cluster", y = "Proportion", fill = "Gender")

# Age distribution
ggplot(df_clean, aes(x = cluster, y = age, fill = cluster)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21) +
  scale_fill_brewer(palette = "Set1") +
  theme_minimal() +
  labs(title = "Age Distribution by Cluster",
       x = "Cluster", y = "Age")


# ============================================================
# 10. STATISTICAL VALIDATION
# ============================================================

# One-way ANOVA: do clusters differ significantly on mental health variables?
cat("\n--- One-way ANOVA Results ---\n")
mental_health_vars <- c("depression_freq", "sleep_issues", "worries",
                        "concentration", "interest_fluct", "seek_validation")

anova_results <- lapply(mental_health_vars, function(v) {
  formula <- as.formula(paste(v, "~ cluster"))
  aov_res  <- aov(formula, data = df_clean)
  s        <- summary(aov_res)[[1]]
  data.frame(variable = v,
             F_value  = round(s$`F value`[1], 2),
             p_value  = round(s$`Pr(>F)`[1], 6))
})
print(knitr::kable(do.call(rbind, anova_results),
                   caption = "ANOVA: Cluster Differences on Mental Health Variables"))
# All F-values > 35, all p < 0.0001 → clusters are statistically distinct.

# Chi-square: gender vs cluster (p=0.29 → gender not a significant driver)
cat("\n--- Chi-square Test: Gender vs Cluster ---\n")
chisq_res <- chisq.test(table(df_clean$gender, df_clean$cluster))
print(chisq_res)
# p > 0.05 → no significant association between gender and cluster membership.
# Age IS a differentiator (cluster 3 avg age 33.9 vs cluster 2 avg age 23.5).