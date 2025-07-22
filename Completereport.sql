-- I. Basic Data Exploration & Overview

-- 		1. Total Number of Activities:
			SELECT 
				COUNT(DISTINCT activity_type) AS total_activity
			FROM cyberreport;
--		2. Number of Unique Users and IP Addresses:
			SELECT 
					COUNT(DISTINCT user_id) AS total_user, 
				    COUNT(DISTINCT ip_address) AS total_ip_address
			FROM cyberreport;
--		3. Distribution of Activity Types:
			SELECT 
				   activity_type,
   				   COUNT(activity_id) AS Activity_Count
			FROM cyberreport
			GROUP BY activity_type
			ORDER BY Activity_Count DESC;
-- 		4. Distribution of Labels (Normal vs. Suspicious):
			SELECT
				 label,
    			 COUNT(activity_id) AS Label_Count,
   			    (COUNT(activity_id) * 100.0 / (SELECT COUNT(*) FROM cyberreport)) AS Percentage
			FROM cyberreport
			GROUP BY label
			ORDER BY Label_Count DESC;
--		5. First and Last Activity Timestamp:
			SELECT 
					MAX(timestamp) AS LAST_ACTIVITY,
					MIN (timestamp) AS FIRST_ACTIVITY
			FROM cyberreport;

--II. Suspicious Activity Analysis

--		6. Total Number of Suspicious Activities:
			SELECT 
					COUNT(activity_type) AS suspicious_activities
			FROM cyberreport
			WHERE label LIKE 'Suspicious';
-- 		7. Breakdown of Anomaly Types (Excluding 'None'):
			SELECT
			    anomaly_type,
			    COUNT(activity_id) AS Anomaly_Count,
			    (COUNT(activity_id) * 100.0 / (SELECT COUNT(*) FROM cyberreport WHERE anomaly_type != 'None')) AS Percentage
			FROM cyberreport
			WHERE anomaly_type != 'None'
			GROUP BY anomaly_type
			ORDER BY Anomaly_Count DESC;
--		 8.	Suspicious Activities by Activity Type:
			SELECT
			    activity_type,
			    COUNT(activity_id) AS Suspicious_Activity_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY activity_type
			ORDER BY Suspicious_Activity_Count DESC;
--		9.	Suspicious Actions by Outcome:	
			SELECT
			    action,
			    COUNT(activity_id) AS Suspicious_Action_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY action
			ORDER BY Suspicious_Action_Count DESC;
--		10.	Combined View: Activity Type, Anomaly Type, and Label Count:
			SELECT
			    activity_type,
			    anomaly_type,
			    label,
			    COUNT(activity_id) AS Event_Count
			FROM cyberreport
			GROUP BY activity_type, anomaly_type, label
			ORDER BY Event_Count DESC;
			
--III. Time-Based Analysis

--		11.	Daily Trend of All Activities:
			SELECT
			    DATE_TRUNC('day', timestamp) AS Activity_Day,
			    COUNT(activity_id) AS Daily_Activity_Count
			FROM cyberreport
			GROUP BY Activity_Day
			ORDER BY Activity_Day;
--		12.	Daily Trend of Suspicious Activities:
			SELECT
			    DATE_TRUNC('day', timestamp) AS Activity_Day,
			    COUNT(activity_id) AS Daily_Suspicious_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY Activity_Day
			ORDER BY Activity_Day;
--		13.	Hourly Distribution of Suspicious Activities:
			SELECT
			    EXTRACT(HOUR FROM timestamp) AS Activity_Hour,
			    COUNT(activity_id) AS Suspicious_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY Activity_Hour
			ORDER BY Activity_Hour;
--		14.	Suspicious Activity by Day of Week:
			SELECT
			    EXTRACT(DOW FROM timestamp) AS Day_Of_Week_Num, 
			    TO_CHAR(timestamp, 'Day') AS Day_Of_Week_Name,
			    COUNT(activity_id) AS Suspicious_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY Day_Of_Week_Num, Day_Of_Week_Name
			ORDER BY Day_Of_Week_Num;
			
--IV. User & IP Address Analysis

--		15.	Top 10 Users by Total Activities:
			SELECT
			    user_id,
			    COUNT(activity_id) AS Total_Activities_Count
			FROM cyberreport
			GROUP BY user_id
			ORDER BY Total_Activities_Count DESC
			LIMIT 10;
--		16.	Top 10 IP Addresses by Suspicious Activities:
			SELECT
			    ip_address,
			    COUNT(activity_id) AS Suspicious_Activities_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY ip_address
			ORDER BY Suspicious_Activities_Count DESC
			LIMIT 10;
--		17.	Users with Multiple Anomaly Types:
			SELECT
			    user_id,
			    COUNT(DISTINCT anomaly_type) AS Distinct_Anomaly_Types,
			    COUNT(activity_id) AS Total_Suspicious_Activities
			FROM cyberreport
			WHERE label = 'Suspicious' AND anomaly_type != 'None'
			GROUP BY user_id
			HAVING COUNT(DISTINCT anomaly_type) > 1
			ORDER BY Distinct_Anomaly_Types DESC, Total_Suspicious_Activities DESC;
--		18.	IP Addresses with Exactly 2 Suspicious Activities (as discussed):
			SELECT
			    ip_address,
			    COUNT(activity_id) AS Suspicious_Activity_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			GROUP BY ip_address
			HAVING COUNT(activity_id) = 2;
			
-- V. File & Login Specific Analysis

--		19.	Average File Size for Suspicious File Activities:
			SELECT
			    AVG(file_size) AS Average_Suspicious_File_Size
			FROM cyberreport
			WHERE label = 'Suspicious'
			AND activity_type IN ('File Access', 'File Modification', 'File Deletion')
			AND file_size > 0;   
--		20.	Top 10 Most Accessed/Modified/Deleted Files (Suspicious):
			SELECT
			    file_name,
			    COUNT(activity_id) AS Suspicious_File_Activity_Count
			FROM cyberreport
			WHERE label = 'Suspicious'
			AND activity_type IN ('File Access', 'File Modification', 'File Deletion')
			AND file_name IS NOT NULL AND file_name != 'Unknown' 
			GROUP BY file_name
			ORDER BY Suspicious_File_Activity_Count DESC
			LIMIT 10;
--		21.	Average Login Attempts for Suspicious Logins (Brute Force):
			SELECT
			    AVG(login_attempts) AS Average_Brute_Force_Attempts
			FROM cyberreport
			WHERE anomaly_type = 'Brute_Force'
			AND login_attempts > 0; 
--		22.	Users with High Failed Login Attempts (Potential Brute Force Source):
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

