# Social Media & Mental Health — Multivariate Analysis

A comprehensive data science project analyzing the relationship between social media usage patterns and mental health outcomes using **PCA**, **K-means clustering**, and **hierarchical clustering**.

**Live Dashboard:** [View Interactive Dashboard](https://github.com/ikramferchichi08/Social-Media-and-Mental-Health)

---

## 📊 Project Overview

This project investigates whether distinct user profiles can be identified from survey data combining:
- **Social media usage habits** (daily time, purpose, distraction)
- **Mental health indicators** (depression, anxiety, sleep issues, concentration)

### Key Findings

Three statistically distinct user clusters identified:

| Cluster | Profile | Size | Avg Usage | Avg Age | Risk Level |
|---------|---------|------|-----------|---------|-----------|
| **1** | High-Impact Heavy Users | 210 (43.7%) | 4-5 hrs/day | 23.5 yrs | 🔴 High |
| **2** | Moderate Passive Users | 198 (41.2%) | 2-3 hrs/day | 26.1 yrs | 🟡 Moderate |
| **3** | Resilient Low-Users | 73 (15.2%) | 1-2 hrs/day | 33.9 yrs | 🟢 Low |

---

## 📁 Project Structure

```
Social-Media-and-Mental-Health/
├── README.md                    # This file
├── smmh_report.tex             # Full LaTeX report with deployment section
├── code.R                       # Main R analysis script
├── newcode.R                    # Additional R analysis
├── smmh.csv                     # Dataset (481 observations, 21 variables)
├── dashboard.html               # Interactive web dashboard
├── report-smmh.pdf             # PDF version of report
└── plots/                       # Generated visualizations
    ├── Capture d'écran 2026-05-20 235720.png  # Age distribution
    ├── Capture d'écran 2026-05-20 235741.png  # Gender distribution
    ├── ... (13 additional plots)
```

---

## 🚀 Quick Start

### Prerequisites
- **R** 4.0 or later ([Download](https://cran.r-project.org/))
- **RStudio** (optional, recommended) ([Download](https://posit.co/download/rstudio-desktop/))
- **2 GB RAM minimum** (4 GB recommended)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ikramferchichi08/Social-Media-and-Mental-Health.git
   cd Social-Media-and-Mental-Health
   ```

2. **Run the analysis:**
   ```r
   setwd("path/to/Social-Media-and-Mental-Health")
   source("code.R")
   ```

   The script will automatically:
   - Install missing packages
   - Load and pre-process the dataset
   - Perform PCA decomposition
   - Execute K-means clustering
   - Run hierarchical clustering validation
   - Generate all visualizations
   - Compute statistical tests (ANOVA, silhouette analysis)

3. **View the interactive dashboard:**
   ```bash
   # Windows PowerShell
   Start-Process "dashboard.html"
   
   # macOS
   open dashboard.html
   
   # Linux
   xdg-open dashboard.html
   ```

**Expected runtime:** 2-5 minutes

---

## 📊 Methodology

### 1. Data Preparation
- **Observations:** 481 survey respondents
- **Variables used:** 13 quantitative variables (Likert scales + ordinal)
- **Missing values:** 0 (complete dataset after selection)
- **Preprocessing:** Column renaming, ordinal encoding, outlier detection (Z-score), standardization

### 2. Principal Component Analysis (PCA)
- **Method:** FactoMineR package
- **Components retained:** 5 PCs (69.9% cumulative variance)
- **PC1 interpretation:** General psychological burden (38.4% variance)
- **PC2 interpretation:** Social comparison vs. passive usage (9.3% variance)

### 3. Clustering
- **Primary method:** K-means (k=3)
- **Validation method:** Hierarchical Agglomerative Clustering (Ward's linkage)
- **Cluster separation:** 89.8% agreement between methods
- **Quality metric:** Silhouette width = 0.224 (acceptable for real-world survey data)

### 4. Statistical Validation
- **ANOVA:** All mental health variables significantly differ by cluster (F > 34, p < 0.0001)
- **Silhouette analysis:** Confirms cluster quality and cohesion
- **Demographic analysis:** Age is a significant differentiator; gender is not

---

## 📈 Interactive Dashboard

The **dashboard.html** file provides:
- Cluster distribution pie chart
- Age distribution boxplot
- Gender distribution by cluster
- Cluster profile heatmap
- Statistical summary tables
- PCA scree plot

**Technology:** Chart.js (client-side, no server required)

---

## 📋 Data Dictionary

| Variable | Scale | Description |
|----------|-------|-------------|
| `daily_usage_ord` | 1-6 (ordinal) | Average daily time on social media |
| `no_purpose` | 1-5 (Likert) | Using social media without purpose |
| `distracted` | 1-5 (Likert) | Getting distracted by social media |
| `restless` | 1-5 (Likert) | Feeling restless without social media |
| `easily_distracted` | 1-5 (Likert) | General ease of distraction |
| `worries` | 1-5 (Likert) | Bothered by worries |
| `concentration` | 1-5 (Likert) | Difficulty concentrating |
| `compare_self` | 1-5 (Likert) | Comparing self to others |
| `comparison_feeling` | 1-5 (Likert) | Feelings about comparisons |
| `seek_validation` | 1-5 (Likert) | Seeking validation from social media |
| `depression_freq` | 1-5 (Likert) | Frequency of depression |
| `interest_fluct` | 1-5 (Likert) | Fluctuation of interest in daily life |
| `sleep_issues` | 1-5 (Likert) | Frequency of sleep problems |

---

## 🛠️ Deployment

### Local Development
Simply open `dashboard.html` in any web browser—no server required.

### Production Deployment
Upload `dashboard.html` to any of these platforms:
- **GitHub Pages:** Free static hosting
- **Netlify:** Drag-and-drop deployment with auto-HTTPS
- **AWS S3 + CloudFront:** Scalable CDN distribution
- **University web server:** Institutional hosting

### API Integration (Optional)
Deploy an R Shiny or plumber API to predict cluster membership for new survey responses:
```r
# Save model for production
saveRDS(pca_model, "pca_model.rds")
saveRDS(kmeans_model, "kmeans_model.rds")

# Load and predict new responses
new_cluster <- predict(kmeans_model, new_pca_scores)
```

---

## 📦 R Packages Used

| Package | Version | Role |
|---------|---------|------|
| tidyverse | 2.x | Data manipulation & visualization |
| FactoMineR | 2.x | Principal Component Analysis |
| factoextra | 1.x | PCA & cluster visualization |
| cluster | 2.x | Silhouette, gap statistic |
| ggplot2 | 3.x | Custom plots |
| corrplot | 0.x | Correlation matrices |
| knitr | 1.x | Table formatting |

---

## 📖 Full Report

See **smmh_report.tex** for the complete academic report including:
- Literature review and research questions
- Detailed methodology
- Comprehensive results with all figures
- Statistical validation
- **New: Deployment & Implementation section**
- Discussion and implications
- Future research directions

Compile with:
```bash
pdflatex smmh_report.tex
pdflatex smmh_report.tex  # Run twice for table of contents
```

---

## 🎯 Key Insights & Recommendations

### For Cluster 1 (High-Impact Heavy Users):
- Targeted digital wellness campaigns
- In-app usage reminders
- Mental health resources & crisis hotlines
- Counselling referral pathways

### For Cluster 2 (Moderate Passive Users):
- Preventive awareness campaigns
- Healthy usage tips
- Peer support groups

### For Cluster 3 (Resilient Low-Users):
- Model for healthy engagement
- Peer mentorship programs
- Reference group for research

---

## 📊 Dataset Source

**Social Media and Mental Health**
- **Source:** Kaggle Open Dataset
- **URL:** https://www.kaggle.com/datasets/souvikahmed071/social-media-and-mental-health
- **License:** Open Access

---

## 👥 Project Team

| Member | Role |
|--------|------|
| Ikram Ferchichi | Data Analysis & Implementation |
| Ghannouchi Malak | Research & Validation |
| Khaled Ayedi | Statistical Analysis |
| Hayder Methneni | Visualization & Reporting |

**Supervised by:** Prof. Ahmed Dhouibi (Statistical Methods and Data Analysis)

**Institution:** TEK-UP University — Data Science & AI Engineering (Class: SDIAE-A)

---

## 📄 Citation

```bibtex
@misc{ferchichi2026smmh,
  title={Social Media and Mental Health: A Multivariate Statistical Analysis},
  author={Ferchichi, Ikram and Malak, Ghannouchi and Ayedi, Khaled and Methneni, Hayder},
  year={2026},
  publisher={GitHub},
  howpublished={\url{https://github.com/ikramferchichi08/Social-Media-and-Mental-Health}}
}
```

---

## 📝 License

This project is open source and available under the MIT License.

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share findings or alternative analyses

---

## 📞 Contact

- **GitHub:** [@ikramferchichi08](https://github.com/ikramferchichi08)
- **Email:** ikramferchichi08@gmail.com

---

## 🔗 Related Resources

- [FactoMineR Documentation](https://cran.r-project.org/web/packages/FactoMineR/)
- [factoextra Guide](https://rpkgs.datanovia.com/factoextra/)
- [PCA Tutorial](https://www.statquest.org/pca-clearly-explained/)
- [K-means Clustering](https://en.wikipedia.org/wiki/K-means_clustering)

---

**Last Updated:** May 22, 2026  
**Status:** ✅ Complete & Deployed
