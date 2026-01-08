#!/usr/bin/env python3
"""
TensorFlow Lite Medical Text Classification Model Training Script for VitalAid
Trains a medical text classifier using the prepared data
"""

import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, LSTM, Embedding, GlobalMaxPooling1D
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.model_selection import train_test_split
import os
import re
from datetime import datetime

# Configuration
VOCAB_SIZE = 1000
MAX_SEQUENCE_LENGTH = 50
EMBEDDING_DIM = 128
HIDDEN_UNITS = 128
BATCH_SIZE = 32
EPOCHS = 30
DROPOUT_RATE = 0.3
VALIDATION_SPLIT = 0.2

def load_medical_data():
    """Load the medical training data"""
    print("Loading medical training data...")
    
    with open('data/medical_training_data.json', 'r', encoding='utf-8') as f:
        medical_data = json.load(f)
    
    texts = []
    labels = []
    
    for item in medical_data:
        texts.append(item['text'])
        labels.append(item['label'])
    
    print(f"Loaded {len(texts)} medical training samples")
    print(f"Number of unique labels: {len(set(labels))}")
    
    return texts, labels

def preprocess_texts(texts):
    """Preprocess and tokenize texts"""
    print("Preprocessing texts...")
    
    # Create tokenizer
    tokenizer = Tokenizer(num_words=VOCAB_SIZE, oov_token="<OOV>")
    tokenizer.fit_on_texts(texts)
    
    # Convert texts to sequences
    sequences = tokenizer.texts_to_sequences(texts)
    
    # Pad sequences
    padded_sequences = pad_sequences(sequences, maxlen=MAX_SEQUENCE_LENGTH, padding='post', truncating='post')
    
    return padded_sequences, tokenizer

def create_classification_model(num_classes):
    """Create a text classification model"""
    print("Creating classification model...")
    
    model = Sequential([
        Embedding(input_dim=VOCAB_SIZE, output_dim=EMBEDDING_DIM, input_length=MAX_SEQUENCE_LENGTH),
        LSTM(HIDDEN_UNITS, return_sequences=True),
        Dropout(DROPOUT_RATE),
        GlobalMaxPooling1D(),
        Dense(64, activation='relu'),
        Dropout(DROPOUT_RATE),
        Dense(num_classes, activation='softmax')
    ])
    
    model.compile(
        optimizer=Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    print("Model created successfully")
    model.summary()
    return model

def train_model(model, X, y):
    """Train the classification model"""
    print("Starting model training...")
    
    # Split data for validation
    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=VALIDATION_SPLIT, random_state=42, stratify=y)
    
    # Callbacks
    early_stopping = EarlyStopping(
        monitor='val_accuracy',
        patience=8,
        restore_best_weights=True,
        verbose=1
    )
    
    reduce_lr = ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=5,
        min_lr=1e-6,
        verbose=1
    )
    
    # Train model
    history = model.fit(
        X_train, y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_val, y_val),
        callbacks=[early_stopping, reduce_lr],
        verbose=1
    )
    
    return history

def convert_to_tflite(model, output_path):
    """Convert Keras model to TensorFlow Lite"""
    print("Converting model to TensorFlow Lite...")
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS
    ]
    converter._experimental_lower_tensor_list_ops = False
    
    tflite_model = converter.convert()
    
    # Save model
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"TFLite model saved to {output_path}")
    return len(tflite_model)

def ensure_directories_exist():
    """Ensure required directories exist"""
    directories = [
        '../assets/models'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"Ensured directory exists: {directory}")

def main():
    """Main training pipeline"""
    print("=== VitalAid Medical Text Classification Model Training ===")
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Configuration: VOCAB_SIZE={VOCAB_SIZE}, MAX_SEQUENCE_LENGTH={MAX_SEQUENCE_LENGTH}")
    print()
    
    # Ensure required directories exist
    ensure_directories_exist()
    
    # Load data
    texts, labels = load_medical_data()
    
    # Get unique labels and create label mapping
    unique_labels = sorted(list(set(labels)))
    num_classes = len(unique_labels)
    label_to_idx = {label: idx for idx, label in enumerate(unique_labels)}
    idx_to_label = {idx: label for label, idx in label_to_idx.items()}
    
    print(f"Number of classes: {num_classes}")
    print(f"Classes: {unique_labels}")
    
    # Convert labels to indices
    label_indices = [label_to_idx[label] for label in labels]
    
    # Preprocess texts
    X, tokenizer = preprocess_texts(texts)
    y = np.array(label_indices)
    
    print(f"Training data shape: X={X.shape}, y={y.shape}")
    
    # Create and train model
    model = create_classification_model(num_classes)
    history = train_model(model, X, y)
    
    # Convert to TFLite
    output_path = '../assets/models/medical_classifier_trained.tflite'
    model_size = convert_to_tflite(model, output_path)
    
    # Save tokenizer and label mappings for inference
    tokenizer_config = {
        'word_index': tokenizer.word_index,
        'index_word': tokenizer.index_word,
        'num_words': tokenizer.num_words,
        'oov_token': tokenizer.oov_token
    }
    
    label_mappings = {
        'label_to_idx': label_to_idx,
        'idx_to_label': idx_to_label,
        'num_classes': num_classes,
        'class_names': [idx_to_label[i] for i in range(num_classes)]
    }
    
    # Save training info
    training_info = {
        'model_info': {
            'vocab_size': VOCAB_SIZE,
            'max_sequence_length': MAX_SEQUENCE_LENGTH,
            'embedding_dim': EMBEDDING_DIM,
            'hidden_units': HIDDEN_UNITS,
            'dropout_rate': DROPOUT_RATE,
            'num_classes': num_classes
        },
        'training_info': {
            'total_samples': len(X),
            'batch_size': BATCH_SIZE,
            'epochs_trained': len(history.history['loss']),
            'final_train_accuracy': float(max(history.history['accuracy'])),
            'final_val_accuracy': float(max(history.history['val_accuracy'])),
            'final_train_loss': float(history.history['loss'][-1]),
            'final_val_loss': float(history.history['val_loss'][-1]),
            'model_size_bytes': model_size
        },
        'class_info': label_mappings,
        'tokenizer_info': tokenizer_config,
        'training_timestamp': datetime.now().isoformat()
    }
    
    # Save configurations
    with open('../assets/models/training_info.json', 'w') as f:
        json.dump(training_info, f, indent=2)
    
    with open('../assets/models/tokenizer.json', 'w') as f:
        json.dump(tokenizer_config, f, indent=2)
    
    with open('../assets/models/labels.json', 'w') as f:
        json.dump(label_mappings, f, indent=2)
    
    print("\n=== Training Complete ===")
    print(f"Model saved to: {output_path}")
    print(f"Model size: {model_size/1024:.1f} KB")
    print(f"Final validation accuracy: {max(history.history['val_accuracy']):.4f}")
    print(f"Training completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()