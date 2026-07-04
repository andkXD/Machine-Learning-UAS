from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import StandardScaler
import joblib
import os

app = Flask(__name__)
CORS(app)

# ── Load kedua model ──────────────────────────────────────
print("Loading models...")
cnn_model    = tf.keras.models.load_model("cnn1d_model.h5")
bilstm_model = tf.keras.models.load_model("bilstm_model.h5")
print("Models loaded successfully!")

# ── Fitur yang dipakai (11 fitur setelah preprocessing) ──
# Urutan HARUS sama persis dengan waktu training:
# CreditScore, Age, Tenure, Balance, NumOfProducts,
# HasCrCard, IsActiveMember, EstimatedSalary,
# Geography_Germany, Geography_Spain, Gender_Male
FEATURE_ORDER = [
    "CreditScore", "Age", "Tenure", "Balance",
    "NumOfProducts", "HasCrCard", "IsActiveMember",
    "EstimatedSalary", "Geography_Germany",
    "Geography_Spain", "Gender_Male"
]

# ── Scaler: fit menggunakan nilai statistik dari dataset asli ──
# Nilai mean & std ini didapat dari dataset Churn_Modelling.csv
# saat training (approximate values untuk production)
MEANS = np.array([
    650.53, 38.92, 5.01, 76485.89,
    1.53, 0.71, 0.52,
    100090.24, 0.0, 0.0, 0.0
])
STDS = np.array([
    96.65, 10.49, 2.89, 62397.41,
    0.58, 0.45, 0.50,
    57510.49, 1.0, 1.0, 1.0
])

def preprocess(data: dict) -> np.ndarray:
    """
    Preprocessing input dari Flutter:
    1. One-hot encode Geography & Gender
    2. Susun fitur sesuai urutan training
    3. StandardScaler
    4. Reshape ke (1, 11, 1) untuk CNN/BiLSTM
    """
    # One-hot encoding Geography
    geo = data.get("Geography", "France")
    geo_germany = 1 if geo == "Germany" else 0
    geo_spain   = 1 if geo == "Spain"   else 0

    # One-hot encoding Gender
    gender     = data.get("Gender", "Male")
    gender_male = 1 if gender == "Male" else 0

    # Susun array fitur
    features = np.array([
        float(data.get("CreditScore",     650)),
        float(data.get("Age",             38)),
        float(data.get("Tenure",          5)),
        float(data.get("Balance",         0)),
        float(data.get("NumOfProducts",   1)),
        float(data.get("HasCrCard",       1)),
        float(data.get("IsActiveMember",  1)),
        float(data.get("EstimatedSalary", 100000)),
        float(geo_germany),
        float(geo_spain),
        float(gender_male),
    ])

    # StandardScaler manual (pakai mean & std dari dataset training)
    features_scaled = (features - MEANS) / (STDS + 1e-8)

    # Reshape ke (1, 11, 1)
    return features_scaled.reshape(1, 11, 1)


# ── Endpoint: Health Check ────────────────────────────────
@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "✅ API Prediksi Churn Bank Berjalan",
        "endpoints": {
            "predict_cnn":    "POST /predict/cnn",
            "predict_bilstm": "POST /predict/bilstm",
            "predict_both":   "POST /predict/both"
        }
    })


# ── Endpoint: Prediksi CNN 1D ─────────────────────────────
@app.route("/predict/cnn", methods=["POST"])
def predict_cnn():
    try:
        data  = request.get_json()
        X     = preprocess(data)
        prob  = float(cnn_model.predict(X, verbose=0)[0][0])
        label = "Churn" if prob >= 0.5 else "Retain"
        return jsonify({
            "model":       "CNN 1D",
            "prediction":  label,
            "probability": round(prob * 100, 2),
            "churn_risk":  round(prob * 100, 2),
            "retain_prob": round((1 - prob) * 100, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# ── Endpoint: Prediksi BiLSTM ─────────────────────────────
@app.route("/predict/bilstm", methods=["POST"])
def predict_bilstm():
    try:
        data  = request.get_json()
        X     = preprocess(data)
        prob  = float(bilstm_model.predict(X, verbose=0)[0][0])
        label = "Churn" if prob >= 0.5 else "Retain"
        return jsonify({
            "model":       "BiLSTM",
            "prediction":  label,
            "probability": round(prob * 100, 2),
            "churn_risk":  round(prob * 100, 2),
            "retain_prob": round((1 - prob) * 100, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


# ── Endpoint: Prediksi Keduanya Sekaligus ─────────────────
@app.route("/predict/both", methods=["POST"])
def predict_both():
    try:
        data = request.get_json()
        X    = preprocess(data)

        # CNN 1D
        prob_cnn    = float(cnn_model.predict(X, verbose=0)[0][0])
        label_cnn   = "Churn" if prob_cnn >= 0.5 else "Retain"

        # BiLSTM
        prob_bilstm  = float(bilstm_model.predict(X, verbose=0)[0][0])
        label_bilstm = "Churn" if prob_bilstm >= 0.5 else "Retain"

        # Model terbaik (BiLSTM biasanya lebih akurat)
        best_model = "BiLSTM"
        best_label = label_bilstm
        best_prob  = prob_bilstm

        return jsonify({
            "cnn1d": {
                "prediction":  label_cnn,
                "churn_risk":  round(prob_cnn * 100, 2),
                "retain_prob": round((1 - prob_cnn) * 100, 2)
            },
            "bilstm": {
                "prediction":  label_bilstm,
                "churn_risk":  round(prob_bilstm * 100, 2),
                "retain_prob": round((1 - prob_bilstm) * 100, 2)
            },
            "best_model":      best_model,
            "final_prediction": best_label,
            "final_probability": round(best_prob * 100, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
