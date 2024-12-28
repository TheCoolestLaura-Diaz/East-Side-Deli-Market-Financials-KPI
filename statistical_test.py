import pandas as pd
from scipy import stats
import scipy.stats as stats

file_path = r"C:\Users\laura\Downloads\store data.csv"
store_data = pd.read_csv(file_path)
print(store_data.head())

# Convert the 'Date' column to datetime with the correct format (example for MM/DD/YYYY)
store_data['Date'] = pd.to_datetime(store_data['Date'], format='%m/%d/%Y')

print(store_data['Date'].head())

# Define the date ranges for before and after periods
before_start_date = pd.to_datetime('2024-04-01')
before_end_date = pd.to_datetime('2024-08-31')
after_start_date = pd.to_datetime('2024-09-01')
after_end_date = pd.to_datetime('2024-12-14')

# Filter data for the 'before' and 'after' periods
before_data = store_data[(store_data['Date'] >= before_start_date) & (store_data['Date'] <= before_end_date)]
after_data = store_data[(store_data['Date'] >= after_start_date) & (store_data['Date'] <= after_end_date)]

# Calculate daily sales for 'before' period
before_daily_sales = before_data.groupby('Date')['Net Sales'].sum()

# Calculate daily sales for 'after' period
after_daily_sales = after_data.groupby('Date')['Net Sales'].sum()

# Calculate average daily sales for each period
avg_before_sales = before_daily_sales.mean()
avg_after_sales = after_daily_sales.mean()

# Create a DataFrame to compare the before and after average sales
periods = ['Before', 'After']
avg_sales = [avg_before_sales, avg_after_sales]
avg_sales_df = pd.DataFrame({
    'Period': periods,
    'Average Daily Sales': avg_sales
})

# Display the resulting DataFrame
print(avg_sales_df)

   Period  Average Daily Sales
0  Before           332.665503
1   After           537.485769

# Perform a two-sample t-test (assumes unequal variance by default)
t_stat, p_value = stats.ttest_ind(before_daily_sales, after_daily_sales)

# Print the results of the t-test
print(f"T-statistic: {t_stat}")

T-statistic: -13.555300851118064

print(f"P-value: {p_value}")

P-value: 8.847635748685619e-32

# Decision based on p-value
alpha = 0.05
if p_value < alpha:
    print("The difference in average daily sales is statistically significant.")
else:
    print("The difference in average daily sales is not statistically significant.")

    
The difference in average daily sales is statistically significant.
