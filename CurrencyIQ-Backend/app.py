# app.py

import requests
import pandas as pd
import numpy as np # Import numpy for an extra check
from flask import Flask, jsonify, request
from datetime import datetime, timedelta
from prophet import Prophet

# --- Configuration ---
app = Flask(__name__)
DAYS_OF_HISTORY_TO_FETCH = 10 * 365

# --- Data Processing Function ---
def fetch_and_prepare_data(base_currency, target_currency, start_date):
    end_date = datetime.now().strftime("%Y-%m-%d")
    api_url = f"https://api.frankfurter.app/{start_date}..{end_date}?from={base_currency}&to={target_currency}"

    try:
        response = requests.get(api_url)
        response.raise_for_status()
        data = response.json()
    except requests.exceptions.RequestException as e:
        print(f"API request failed: {e}")
        return None

    rate_data = data.get('rates', {})
    processed_data = []
    for date_str, rate_dict in rate_data.items():
        if target_currency in rate_dict:
            processed_data.append({"ds": date_str, "y": rate_dict[target_currency]})

    processed_data.sort(key=lambda x: x['ds'])
    df = pd.DataFrame(processed_data)
    df['ds'] = pd.to_datetime(df['ds'])
    return df

# --- Prediction Endpoint ---
@app.route('/predict', methods=['GET'])
def predict_rates():
    base = request.args.get('base')
    target = request.args.get('target')
    display_range = request.args.get('range', '1y')

    today = datetime.now()
    if display_range == '6m':
        days_to_fetch = 180
    elif display_range == '5y':
        days_to_fetch = 5 * 365
    elif display_range == 'max':
        days_to_fetch = 25 * 365
    else:
        days_to_fetch = 365
        
    model_fetch_start_date = (today - timedelta(days=max(days_to_fetch, 3*365))).strftime("%Y-%m-%d")
    display_start_date = today - timedelta(days=days_to_fetch)

    prepared_df = fetch_and_prepare_data(base, target, model_fetch_start_date)
    if prepared_df is None or prepared_df.empty:
        return jsonify({"error": "Could not retrieve data for modeling."}), 500

    model = Prophet(daily_seasonality=True)
    model.fit(prepared_df)

    future = model.make_future_dataframe(periods=30)
    forecast = model.predict(future)

    # --- DATA CLEANING AND FORMATTING ---
    
    # 1. NEW: Clean invalid numbers (NaN/Inf) created by Prophet instability.
    # Replace infinite values with NaN, then drop rows containing NaN for critical columns.
    forecast.replace([np.inf, -np.inf], np.nan, inplace=True)
    forecast = forecast.dropna(subset=['yhat', 'yhat_lower', 'yhat_upper'])

    # 2. Add 'type' column and filter based on display range requested by user
    forecast['type'] = forecast['ds'].apply(lambda x: 'forecast' if x > today else 'history')
    
    # 3. Create an explicit copy to avoid the SettingWithCopyWarning
    display_data = forecast[forecast['ds'] >= display_start_date].copy()
    
    # 4. Prepare results for JSON response
    final_results = display_data[['ds', 'yhat', 'yhat_lower', 'yhat_upper', 'type']]
    final_results['ds'] = final_results['ds'].dt.strftime('%Y-%m-%d')

    return jsonify(final_results.to_dict(orient='records'))

if __name__ == '__main__':
    app.run(debug=True, port=5001)