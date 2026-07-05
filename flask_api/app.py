from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import tensorflow as tf
import os

app = Flask(__name__)
CORS(app)

print("Loading models...")
cnn_model    = tf.keras.models.load_model("cnn1d_model.h5")
bilstm_model = tf.keras.models.load_model("bilstm_model.h5")
print("Models loaded successfully!")

FEATURE_ORDER = [
    "CreditScore", "Age", "Tenure", "Balance",
    "NumOfProducts", "HasCrCard", "IsActiveMember",
    "EstimatedSalary", "Geography_Germany",
    "Geography_Spain", "Gender_Male"
]

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
    geo = data.get("Geography", "France")
    geo_germany = 1 if geo == "Germany" else 0
    geo_spain   = 1 if geo == "Spain"   else 0
    gender      = data.get("Gender", "Male")
    gender_male = 1 if gender == "Male" else 0

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

    features_scaled = (features - MEANS) / (STDS + 1e-8)
    return features_scaled.reshape(1, 11, 1)


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


@app.route("/predict/cnn", methods=["POST"])
def predict_cnn():
    try:
        data  = request.get_json()
        X     = preprocess(data)
        prob  = float(cnn_model.predict(X, verbose=0)[0][0])
        label = "Churn" if prob >= 0.5 else "Retain"
        conf  = prob if prob >= 0.5 else (1 - prob)
        return jsonify({
            "model":       "CNN 1D",
            "prediction":  label,
            "churn_risk":  round(prob * 100, 2),
            "retain_prob": round((1 - prob) * 100, 2),
            "confidence":  round(conf * 100, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/predict/bilstm", methods=["POST"])
def predict_bilstm():
    try:
        data  = request.get_json()
        X     = preprocess(data)
        prob  = float(bilstm_model.predict(X, verbose=0)[0][0])
        label = "Churn" if prob >= 0.5 else "Retain"
        conf  = prob if prob >= 0.5 else (1 - prob)
        return jsonify({
            "model":       "BiLSTM",
            "prediction":  label,
            "churn_risk":  round(prob * 100, 2),
            "retain_prob": round((1 - prob) * 100, 2),
            "confidence":  round(conf * 100, 2)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/predict/both", methods=["POST"])
def predict_both():
    try:
        data = request.get_json()
        X    = preprocess(data)

        prob_cnn    = float(cnn_model.predict(X, verbose=0)[0][0])
        label_cnn   = "Churn" if prob_cnn >= 0.5 else "Retain"

        prob_bilstm  = float(bilstm_model.predict(X, verbose=0)[0][0])
        label_bilstm = "Churn" if prob_bilstm >= 0.5 else "Retain"

        conf_cnn    = prob_cnn    if prob_cnn    >= 0.5 else (1 - prob_cnn)
        conf_bilstm = prob_bilstm if prob_bilstm >= 0.5 else (1 - prob_bilstm)

        if conf_cnn >= conf_bilstm:
            best_model = "CNN 1D"
            best_label = label_cnn
            best_prob  = prob_cnn
            best_conf  = conf_cnn
            reason     = (
                f"CNN 1D lebih yakin dengan prediksi '{label_cnn}' "
                f"(confidence {round(conf_cnn*100,1)}%) "
                f"dibanding BiLSTM (confidence {round(conf_bilstm*100,1)}%)"
            )
        else:
            best_model = "BiLSTM"
            best_label = label_bilstm
            best_prob  = prob_bilstm
            best_conf  = conf_bilstm
            reason     = (
                f"BiLSTM lebih yakin dengan prediksi '{label_bilstm}' "
                f"(confidence {round(conf_bilstm*100,1)}%) "
                f"dibanding CNN 1D (confidence {round(conf_cnn*100,1)}%)"
            )

        agreement = "Kedua model sepakat" if label_cnn == label_bilstm else "Kedua model berbeda pendapat"

        return jsonify({
            "cnn1d": {
                "prediction":  label_cnn,
                "churn_risk":  round(prob_cnn * 100, 2),
                "retain_prob": round((1 - prob_cnn) * 100, 2),
                "confidence":  round(conf_cnn * 100, 2)
            },
            "bilstm": {
                "prediction":  label_bilstm,
                "churn_risk":  round(prob_bilstm * 100, 2),
                "retain_prob": round((1 - prob_bilstm) * 100, 2),
                "confidence":  round(conf_bilstm * 100, 2)
            },
            "best_model":        best_model,
            "final_prediction":  best_label,
            "final_probability": round(best_prob * 100, 2),
            "best_confidence":   round(best_conf * 100, 2),
            "reason":            reason,
            "agreement":         agreement
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)