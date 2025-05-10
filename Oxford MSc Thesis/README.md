# Clustering Nintendo Switch Players Using K-Means on Digital Trace Data and Examining Well-Being via Survey-Based Moderation Analysis

 **Abstract**  
This study explored the relationship between video game playtime and well-being using two weeks of objective Nintendo Switch gameplay data. It investigated whether distinct player profiles could be identified based on playtime and play mode (handheld vs docked), and whether satisfaction or frustration of basic psychological needs moderated the relationship between these profiles and well-being. Using digital trace data and K-means clustering, three player profiles were identified. While no significant relationship was found between playtime or profiles and well-being, need satisfaction was strongly associated with higher well-being. The study suggests a shift in focus from regulating playtime to designing psychologically enriching game experiences.

---

##  Research Questions

1. Is there a relationship between gaming play time and well-being?  
2.1 Can meaningful subgroups of players be identified based on their play time and play mode?  
2.2 Do need satisfaction and frustration in games moderate the relationship between player profiles and well-being?

---

## 🛠 Methodology
- **Digital Trace Data**: Objective play history (session length, play mode) retrieved from Nintendo of America via account linking
- **Survey Instruments**:
  - Warwick-Edinburgh Mental Well-being Scale (WEMWBS)
  - Basic Needs in Games Scale (BANGS) measuring autonomy, competence, and relatedness (satisfaction & frustration)

### 📊 Clustering Analytical Approach

#### 1. **Clustering Tendency Assessment**
- Used **Visual Assessment of Tendency (VAT)** plots and the **Hopkins statistic (H = 0.90)** to confirm that clustering structure existed in the dataset.

#### 2. **K-means Clustering**
- Features: total playtime and proportion of time in handheld vs docked mode
- Chose **K = 3** clusters based on the **elbow method**, **gap statistic**, and **silhouette validation**
- Final clusters:
  - *Moderate Handheld Enthusiasts*
  - *Frequent and Versatile Players*
  - *Consistent Docked Players*

#### 3. **Cluster Validation**
- Used **Silhouette Score (avg = 0.77)** and **Dunn Index (0.24)** to confirm good separation and cohesion
- Interpreted clusters with descriptive statistics and visualized them in 2D space

#### 4. **Regression & Moderation Analysis**
- Used **multiple linear regression** to test if playtime predicted well-being (it did not)
- Assessed moderation of player cluster × psychological needs using interaction terms

##  Key Findings

- No significant link between raw playtime and well-being  
-  Three behavioral profiles were identified:  
  - *Moderate Handheld Enthusiasts*  
  - *Frequent & Versatile Players*  
  - *Consistent Docked Players*  
-  Need satisfaction (autonomy, competence, relatedness) was **strongly predictive of well-being**, independent of profile or playtime  
-  Suggests that current digital wellness policies focusing on screen time are overly simplistic  

---

### 🛠 Tools & Libraries
- **Language**: R
- **Libraries**: `tidyverse`, `cluster`, `factoextra`, `clustertend`, `car`, `psych`, `fpc`
- **Platform**: Qualtrics (survey), RStudio

## 🔒 Ethics & Data Access
All data collection and analysis followed approval from the **University of Oxford’s Central University Research Ethics Committee (CUREC)**. Individual digital trace data is **anonymized** and cannot be publicly shared due to privacy considerations.

---

## 📬 Contact
For questions or discussion, feel free to connect via [LinkedIn](https://www.linkedin.com/in/rominakarkalou/) or email: romina.karkalou@outlook.com
