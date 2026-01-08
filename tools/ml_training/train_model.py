#!/usr/bin/env python3
"""
TensorFlow Lite Model Training Script for VitalAid
Trains a medical chatbot model using the prepared data
"""

import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, LSTM
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
import os
import re
import random
from datetime import datetime

# Configuration
VOCAB_SIZE = 1000
MAX_SEQUENCE_LENGTH = 50
EMBEDDING_DIM = 128
HIDDEN_UNITS = 256
BATCH_SIZE = 32
EPOCHS = 50
DROPOUT_RATE = 0.3

def load_data():
    """Load the prepared training data"""
    print("Loading prepared data...")
    
    with open('data/conversations.json', 'r', encoding='utf-8') as f:
        conversations = json.load(f)
    
    with open('data/vocabulary.json', 'r', encoding='utf-8') as f:
        vocabulary = json.load(f)
    
    print(f"Loaded {len(conversations)} conversations")
    print(f"Vocabulary size: {len(vocabulary)}")
    
    return conversations, vocabulary

def tokenize_text(text, vocabulary, max_length=MAX_SEQUENCE_LENGTH):
    """Convert text to sequence of token IDs"""
    tokens = text.lower().split()
    token_ids = []
    
    # Add START token
    token_ids.append(vocabulary.get('<START>', 2))
    
    for token in tokens:
        token_id = vocabulary.get(token, vocabulary.get('<UNK>', 1))
        token_ids.append(token_id)
    
    # Add END token
    token_ids.append(vocabulary.get('<END>', 3))
    
    # Pad or truncate to max_length
    if len(token_ids) > max_length:
        token_ids = token_ids[:max_length]
    else:
        token_ids.extend([vocabulary.get('<PAD>', 0)] * (max_length - len(token_ids)))
    
    return np.array(token_ids)

def create_synthetic_training_data(conversations, vocabulary, num_samples=1000):
    """Create synthetic training data for the medical chatbot"""
    print(f"Creating {num_samples} synthetic training samples...")
    
    # Common medical emergency patterns
    emergency_patterns = [
        ("chest pain", "Chest pain can be serious. Sit the person down, loosen tight clothing, and call emergency services immediately. If they become unconscious, start CPR."),
        ("difficulty breathing", "Help the person sit upright, loosen tight clothing, and call emergency services. If breathing stops, begin rescue breathing."),
        ("severe bleeding", "Apply direct pressure with clean cloth. Elevate the injured area if possible. Call emergency services for severe bleeding."),
        ("burn injury", "Cool the burn with cool water for 10-20 minutes. Remove jewelry before swelling occurs. Do not apply ice or break blisters."),
        ("choking", "For adults: Perform abdominal thrusts (Heimlich maneuver). For infants: Give 5 back blows then 5 chest thrusts. Call emergency services if unsuccessful."),
        ("seizure", "Time the seizure. Do not restrain. Protect the head with something soft. Turn on side if vomiting occurs after."),
        ("unconscious person", "Check for breathing and pulse. If no pulse, start CPR immediately. Call emergency services for any unconscious person."),
        ("allergic reaction", "Help person sit upright. Give antihistamine if available. Call emergency services for severe reactions (swelling, difficulty breathing)."),
        ("fracture", "Immobilize the area. Apply ice to reduce swelling. Do not move the person unnecessarily. Call emergency services."),
        ("poisoning", "Call poison control immediately. Do not induce vomiting unless directed. Bring the container/p substance to the hospital."),
        ("stroke", "Remember FAST: Face drooping, Arms weakness, Speech difficulty, Time to call emergency services."),
        ("heat stroke", "Move to cool area. Remove excess clothing. Cool with water/fans. Call emergency services for severe symptoms."),
        ("hypothermia", "Move to warm, dry area. Remove wet clothes. Warm gradually with blankets/body heat. Do not massage extremities."),
        ("electric shock", "Do not touch the person until power source is off. Call emergency services. Check for burns and breathing."),
        ("diabetic emergency", "If conscious, give sugar/glucose. If unconscious, do not give anything by mouth. Call emergency services."),
        ("head injury", "Do not move the person. Keep them still. Call emergency services for any serious head injury."),
        ("eye injury", "Do not rub the eye. Rinse with clean water. Cover both eyes to reduce movement. Seek medical attention."),
        ("sprain", "Rest, ice, compression, elevation (RICE). Avoid heat and movement for first 24-48 hours."),
        ("animal bite", "Clean wound thoroughly with soap and water. Apply pressure to stop bleeding. Get medical attention for rabies risk."),
        ("severe allergic reaction", "Use epinephrine auto-injector if available. Call emergency services immediately. Monitor breathing and pulse."),
    ]
    
    # Create synthetic input-output pairs
    X = []
    y = []
    
    # Add real conversation data if available
    for conv in conversations[:len(conversations)//2]:  # Use first half of real data
        if 'user_input' in conv and 'bot_response' in conv:
            input_tokens = tokenize_text(conv['user_input'], vocabulary)
            output_tokens = tokenize_text(conv['bot_response'], vocabulary)
            X.append(input_tokens)
            y.append(output_tokens)
    
    # Generate synthetic medical emergency conversations
    for i in range(num_samples):
        # Randomly select an emergency pattern
        question, answer = random.choice(emergency_patterns)
        
        # Add some variation to the questions
        variations = [
            f"What should I do if someone has {question}?",
            f"Emergency: {question}",
            f"How to treat {question}?",
            f"Help with {question}",
            f"What to do about {question}?",
            f"{question} - what to do?",
            f"I need help with {question}",
            f"How to handle {question}?",
        ]
        
        input_text = random.choice(variations)
        output_text = answer
        
        # Tokenize
        input_tokens = tokenize_text(input_text, vocabulary)
        output_tokens = tokenize_text(output_text, vocabulary)
        
        X.append(input_tokens)
        y.append(output_tokens)
        
        # Add some variations with slight modifications
        if random.random() < 0.3:  # 30% chance for variation
            input_text = input_text.replace("what should", "what do I").replace("how to", "how do I")
            input_tokens = tokenize_text(input_text, vocabulary)
            output_tokens = tokenize_text(output_text, vocabulary)
            
            X.append(input_tokens)
            y.append(output_tokens)
    
    X = np.array(X)
    y = np.array(y)
    
    print(f"Created training data: X shape {X.shape}, y shape {y.shape}")
    return X, y

def create_model():
    """Create the neural network model"""
    print("Creating neural network model...")
    
    model = Sequential([
        LSTM(HIDDEN_UNITS, input_shape=(MAX_SEQUENCE_LENGTH, 1), return_sequences=True),
        Dropout(DROPOUT_RATE),
        LSTM(HIDDEN_UNITS//2, return_sequences=False),
        Dropout(DROPOUT_RATE),
        Dense(256, activation='relu'),
        Dropout(DROPOUT_RATE),
        Dense(128, activation='relu'),
        Dense(VOCAB_SIZE, activation='softmax')
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
    """Train the model"""
    print("Starting model training...")
    
    # Reshape data for LSTM (add channel dimension)
    X = X.reshape(X.shape[0], X.shape[1], 1)
    
    # Callbacks
    early_stopping = EarlyStopping(
        monitor='val_loss',
        patience=10,
        restore_best_weights=True
    )
    
    reduce_lr = ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=5,
        min_lr=1e-6
    )
    
    # Train model
    history = model.fit(
        X, y,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_split=0.2,
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
        'data',
        '../assets/models'
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"Ensured directory exists: {directory}")
    print()

def main():
    """Main training pipeline"""
    print("=== VitalAid TensorFlow Lite Model Training ===")
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Configuration: VOCAB_SIZE={VOCAB_SIZE}, MAX_SEQUENCE_LENGTH={MAX_SEQUENCE_LENGTH}")
    print()
    
    # Ensure required directories exist
    ensure_directories_exist()
    
    # Load data
    conversations, vocabulary = load_data()
    
    # Create training data
    X, y = create_synthetic_training_data(conversations, vocabulary, num_samples=1000)
    
    # Create and train model
    model = create_model()
    history = train_model(model, X, y)
    
    # Convert to TFLite
    output_path = '../assets/models/medical_chatbot.tflite'
    model_size = convert_to_tflite(model, output_path)
    
    # Save training info
    training_info = {
        'model_info': {
            'vocab_size': VOCAB_SIZE,
            'max_sequence_length': MAX_SEQUENCE_LENGTH,
            'embedding_dim': EMBEDDING_DIM,
            'hidden_units': HIDDEN_UNITS,
            'dropout_rate': DROPOUT_RATE
        },
        'training_info': {
            'total_samples': len(X),
            'batch_size': BATCH_SIZE,
            'epochs_trained': len(history.history['loss']),
            'final_train_loss': float(history.history['loss'][-1]),
            'final_val_loss': float(history.history['val_loss'][-1]),
            'model_size_bytes': model_size
        },
        'training_timestamp': datetime.now().isoformat()
    }
    
    with open('training_info.json', 'w') as f:
        json.dump(training_info, f, indent=2)
    
    print("\n=== Training Complete ===")
    print(f"Model saved to: {output_path}")
    print(f"Model size: {model_size/1024:.1f} KB")
    print(f"Final validation loss: {history.history['val_loss'][-1]:.4f}")
    print(f"Training completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()