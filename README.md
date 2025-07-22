# Cybercrime Forensic Analysis Dashboard

## Project Overview

This project focuses on building a comprehensive and interactive **Cybercrime Forensic Analysis Dashboard** to detect, monitor, and investigate suspicious activities within system operational logs. Leveraging a simulated dataset of cyber events, this solution aims to provide cybersecurity professionals and data analysts with actionable insights to enhance threat detection and incident response capabilities.

**Key Technologies Used:** PostgreSQL, pgAdmin, Power BI, Power Query, DAX, SQL.

## Business Problem & Goal

In today's digital landscape, organizations face an ever-increasing volume of cyber threats. Manually sifting through vast operational logs to identify malicious activity is inefficient and prone to human error.

**The primary goal of this project is to:**
* Transform raw, complex cyber activity data into clear, actionable intelligence.
* Enable proactive identification of suspicious patterns and anomalies.
* Provide a centralized, interactive platform for security teams to monitor system health and prioritize forensic investigations.

## Dataset

The analysis utilizes a **Cybercrime Forensic Dataset** comprising **7,400 observations**, simulating various network activities, file management, and system access events.
* **Source:** [Link to Kaggle dataset, e.g., `https://www.kaggle.com/datasets/your-dataset-name`]
* **Key Columns:** `Timestamp`, `User_ID`, `IP_Address`, `Activity_Type`, `Action`, `Login_Attempts`, `File_Size`, `Anomaly_Type`, `Label` (Normal/Suspicious).

## Analytical Process & Methodology

1.  **Data Acquisition & Database Setup:**
    * Acquired the raw cybercrime forensic data in CSV format.
    * Set up a dedicated **PostgreSQL database (`cyber_forensics_db`)** to store and manage the data.
    * **Resolved a critical `invalid byte sequence for encoding "UTF8"` error** during initial import by pre-cleaning the CSV to remove hidden null bytes.
    * Implemented an **auto-incrementing `activity_id` (SERIAL PRIMARY KEY)** to ensure unique identification for each event.

2.  **Data Cleaning & Transformation (PostgreSQL & Power Query):**
    * Performed initial data profiling in PostgreSQL to understand column distributions and data quality.
    * Utilized **Power Query (within Power BI)** for robust data cleaning and transformation:
        * Handled blank/null values: Replaced `NULL` in `File_Name` with "Unknown", `Login_Attempts` with `0`, and `File_Size` with `0.0` (aligning with decimal format) to ensure data integrity and accurate calculations.
        * Standardized text fields (e.g., `Activity_Type`, `Anomaly_Type`) by capitalizing words and replacing underscores with spaces for enhanced readability in visualizations.
        * Ensured correct data types for all columns (e.g., `Timestamp` as Date/Time, `Login_Attempts` as Whole Number, `File_Size` as Decimal Number).

3.  **Data Modeling & DAX Measures (Power BI):**
    * Loaded the cleaned data into Power BI Desktop, ensuring a robust data model.
    * Created key **DAX measures** for advanced calculations, including:
        * `% Suspicious Activities`: Calculated the percentage of suspicious events relative to total activities.
        * `Suspicious Activities per IP`: Counted suspicious events for each IP address, enabling targeted filtering.

4.  **Interactive Dashboard Development (Power BI):**
    * Designed and built a multi-faceted interactive dashboard in Power BI, incorporating various visual types to present insights effectively.
    * **[https://vitacin-my.sharepoint.com/:u:/g/personal/prabhat_dutta2021_vitstudent_ac_in/EeqOl-lLFJ1Kh-lkTO8EIvMBfPzUkn-YiNhgMecddgA4qA?e=3GXhdP]*
*

## SQL Analysis

The following SQL queries were instrumental in exploring, transforming, and extracting key insights from the `cyberreport` dataset in PostgreSQL. These queries underpin the data presented in the Power BI dashboard.

### I. Basic Data Exploration & Overview

### 1. Total Number of Activities:
```sql
SELECT
	   COUNT(activity_id) AS total_activities -- Corrected to count activity_id for total rows
      FROM cyberreport;
```
### 2. Number of Unique Users and IP Addresses:
```sql
SELECT
      COUNT(DISTINCT user_id) AS total_user,
      COUNT(DISTINCT ip_address) AS total_ip_address
FROM cyberreport;
```
### 3. Distribution of Activity Types:
```sql
SELECT
		activity_type,
   	COUNT(activity_id) AS Activity_Count
FROM cyberreport
GROUP BY activity_type
ORDER BY Activity_Count DESC;
```
### 4. Distribution of Labels (Normal vs. Suspicious):
```sql
SELECT
		label,
    	COUNT(activity_id) AS Label_Count,
   	(COUNT(activity_id) * 100.0 / (SELECT COUNT(*) FROM cyberreport)) AS Percentage
FROM cyberreport
GROUP BY label
ORDER BY Label_Count DESC;
```
### 5. First and Last Activity Timestamp:
```sql
SELECT
		MAX(timestamp) AS LAST_ACTIVITY,
		MIN (timestamp) AS FIRST_ACTIVITY
FROM cyberreport;
```
### II. Suspicious Activity Analysis

### 6. Total Number of Suspicious Activities:
```sql
SELECT
		COUNT(activity_type) AS suspicious_activities
FROM cyberreport
WHERE label LIKE 'Suspicious';
```

### 7. Breakdown of Anomaly Types (Excluding 'None'):
```sql
SELECT
		anomaly_type,
		COUNT(activity_id) AS Anomaly_Count,
		(COUNT(activity_id) * 100.0 / (SELECT COUNT(*) FROM cyberreport WHERE anomaly_type != 'None')) AS Percentage
FROM cyberreport
WHERE anomaly_type != 'None'
GROUP BY anomaly_type
ORDER BY Anomaly_Count DESC;
```
### 8.Suspicious Activities by Activity Type:
```sql
SELECT
		activity_type,
		COUNT(activity_id) AS Suspicious_Activity_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY activity_type
ORDER BY Suspicious_Activity_Count DESC;
```
### 9.	Suspicious Actions by Outcome:
```sql
SELECT
		action,
		COUNT(activity_id) AS Suspicious_Action_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY action
ORDER BY Suspicious_Action_Count DESC;
```
### 10.	Combined View: Activity Type, Anomaly Type, and Label Count:
```sql
SELECT
	   activity_type,
		anomaly_type,
	   label,
COUNT(activity_id) AS Event_Count
FROM cyberreport
GROUP BY activity_type, anomaly_type, label
ORDER BY Event_Count DESC;
```
### III. Time-Based Analysis

### 11.	Daily Trend of All Activities:
```sql
SELECT
      DATE_TRUNC('day', timestamp) AS Activity_Day,
      COUNT(activity_id) AS Daily_Activity_Count
FROM cyberreport
GROUP BY Activity_Day
ORDER BY Activity_Day;
```
### 12.	Daily Trend of Suspicious Activities:
```sql
SELECT
      DATE_TRUNC('day', timestamp) AS Activity_Day,
      COUNT(activity_id) AS Daily_Suspicious_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY Activity_Day
ORDER BY Activity_Day;
```
### 13.	Hourly Distribution of Suspicious Activities:
```sql
SELECT
      EXTRACT(HOUR FROM timestamp) AS Activity_Hour,
      COUNT(activity_id) AS Suspicious_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY Activity_Hour
ORDER BY Activity_Hour;
```

### 14.	Suspicious Activity by Day of Week:
```sql
SELECT
      EXTRACT(DOW FROM timestamp) AS Day_Of_Week_Num,
      TO_CHAR(timestamp, 'Day') AS Day_Of_Week_Name,
      COUNT(activity_id) AS Suspicious_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY Day_Of_Week_Num, Day_Of_Week_Name
ORDER BY Day_Of_Week_Num;
```
### IV. User & IP Address Analysis

### 15.Top 10 Users by Total Activities:
```sql		
SELECT
      user_id,
      COUNT(activity_id) AS Total_Activities_Count
FROM cyberreport
GROUP BY user_id
ORDER BY Total_Activities_Count DESC
LIMIT 10;
```
### 16. Top 10 IP Addresses by Suspicious Activities:
```sql			
SELECT
      ip_address,
      COUNT(activity_id) AS Suspicious_Activities_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY ip_address
ORDER BY Suspicious_Activities_Count DESC
LIMIT 10;
```
### 17. Users with Multiple Anomaly Types:
```sql			
SELECT
      user_id,
      COUNT(DISTINCT anomaly_type) AS Distinct_Anomaly_Types,
      COUNT(activity_id) AS Total_Suspicious_Activities
FROM cyberreport
WHERE label = 'Suspicious' AND anomaly_type != 'None'
GROUP BY user_id
HAVING COUNT(DISTINCT anomaly_type) > 1
ORDER BY Distinct_Anomaly_Types DESC, Total_Suspicious_Activities DESC;
```
### 18. IP Addresses with Exactly 2 Suspicious Activities (as discussed):
```sql			
SELECT
      ip_address,
      COUNT(activity_id) AS Suspicious_Activity_Count
FROM cyberreport
WHERE label = 'Suspicious'
GROUP BY ip_address
HAVING COUNT(activity_id) = 2;
```
### V. File & Login Specific Analysis

### 19. Average File Size for Suspicious File Activities:
```sql
SELECT
      AVG(file_size) AS Average_Suspicious_File_Size
FROM cyberreport
WHERE label = 'Suspicious' AND activity_type IN ('File Access', 'File Modification', 'File Deletion')
			                  AND file_size > 0;
```
### 20. Top 10 Most Accessed/Modified/Deleted Files (Suspicious):
```sql
SELECT
      file_name,
      COUNT(activity_id) AS Suspicious_File_Activity_Count
FROM cyberreport
WHERE label = 'Suspicious' AND activity_type IN ('File Access', 'File Modification', 'File Deletion')
			                  AND file_name IS NOT NULL AND file_name != 'Unknown'
GROUP BY file_name
ORDER BY Suspicious_File_Activity_Count DESC
LIMIT 10;
```
### 21. Average Login Attempts for Suspicious Logins (Brute Force):
```sql
SELECT
      AVG(login_attempts) AS Average_Brute_Force_Attempts
FROM cyberreport
WHERE anomaly_type = 'Brute_Force' AND login_attempts > 0;
```
### 22. Users with High Failed Login Attempts (Potential Brute Force Source):
```sql
SELECT
      user_id,
      ip_address,
      SUM(login_attempts) AS Total_Login_Attempts,
      COUNT(activity_id) AS Failed_Login_Count
FROM cyberreport
WHERE activity_type = 'Login' AND action = 'Failed'
GROUP BY user_id, ip_address
HAVING SUM(login_attempts) > 5
ORDER BY Total_Login_Attempts DESC;
```

## Key Dashboard Highlights & Analytical Insights

The dashboard provides a dynamic view of potential security incidents, enabling quick identification and deeper investigation:

* **Overall Security Posture:** High-level KPIs (Total Activities, Total Suspicious Events, % Suspicious Activities, Total Anomalies Flagged) provide an immediate snapshot of the system's threat landscape.
* **Threat Trends Over Time:** A line chart visualizes daily/hourly trends of total vs. suspicious activities, highlighting spikes or recurring patterns that may indicate targeted attacks or vulnerabilities.
* **Dominant Anomaly Types:** Bar charts clearly show the most prevalent anomaly types (e.g., Brute Force, Data Exfiltration, DDoS Attempt, USB Access), guiding focused defense strategies.
* **Exploited Activity Vectors:** Stacked bar charts reveal which specific activity types (e.g., Login, File Access) are most frequently associated with suspicious flags, pinpointing common attack methods.
* **Targeted Entity Identification (Key Finding):**
    * A dedicated table identifies **[Number, e.g., 29] IP addresses** that appeared exactly twice in suspicious activities, suggesting repeated attempts from specific sources.
    * **Critical Insight:** Further analysis revealed that for **[Number, e.g., 28] of these IPs, `Login_Attempts` were `0`**, indicating automated, non-login-based reconnaissance. However, for **1 specific IP address, `Login_Attempts` were non-zero**, signifying a persistent and potentially successful unauthorized access attempt. This IP is flagged for immediate, high-priority forensic investigation.
* **Granular Investigation:** An interactive table allows security analysts to drill down into specific suspicious events, tracing actions by `User_ID`, `IP_Address`, `Timestamp`, and `Anomaly_Type`.

## Actionable Recommendations

Based on the insights from this dashboard, an organization could:

* **Prioritize Investigation:** Immediately investigate the identified critical IP address with repeated login attempts.
* **Strengthen Defenses:** Implement enhanced security measures against the most prevalent anomaly types (e.g., stronger brute-force protection, data loss prevention for exfiltration).
* **Monitor Key Activity Types:** Increase vigilance on `[e.g., Login]` and `[e.g., File Access]` activities, as they are frequently exploited.
* **Automate Alerts:** Configure real-time alerts for spikes in suspicious activities or specific anomaly types identified in the trends.

## How to View the Dashboard

The interactive Power BI dashboard can be viewed live online:
**[Insert your Power BI Publish to Web URL here]**

<img width="1523" height="857" alt="image" src="https://github.com/user-attachments/assets/d8af3667-e43e-4aa1-ac8b-dd357e9836e0" />

## Future Enhancements

* Integration of additional data sources (e.g., firewall logs, endpoint detection data) for a more holistic view.
* Development of more sophisticated anomaly detection algorithms (e.g., using Python for statistical process control or basic machine learning models) to reduce false positives.
* Implementation of role-based access control (RLS) within Power BI for different security team roles.

## Connect with Me

Feel free to connect with me on LinkedIn or reach out via email for any questions or collaboration opportunities.

* **LinkedIn:** https://www.linkedin.com/in/prabhat-dutta-29265b201/
* **Email:** prabhatdutta1911@gmail.com
