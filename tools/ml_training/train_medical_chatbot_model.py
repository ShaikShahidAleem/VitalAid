#!/usr/bin/env python3
"""
Medical Chatbot Model Training Script
Trains a neural network for medical query classification
"""

import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Embedding, LSTM, GlobalMaxPooling1D
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
from typing import List, Dict, Tuple
import os

class MedicalChatbotTrainer:
    def __init__(self, max_words: int = 5000, max_length: int = 50):
        self.max_words = max_words
        self.max_length = max_length
        self.tokenizer = None
        self.model = None
        self.history = None
        self.categories = None
        self.reverse_categories = None
        
    def load_data(self, data_file: str = 'medical_chatbot_training_data.json') -> Tuple[List[str], List[int]]:
        """Load training data from JSON file"""
        with open(data_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        self.categories = data['categories']
        self.reverse_categories = data['reverse_categories']
        training_data = data['training_data']
        
        texts = [item['text'] for item in training_data]
        labels = [item['label'] for item in training_data]
        
        print(f"Loaded {len(texts)} training samples")
        print(f"Categories: {list(self.categories.keys())}")
        
        return texts, labels
    
    def preprocess_data(self, texts: List[str], labels: List[int]) -> Tuple[np.ndarray, np.ndarray]:
        """Preprocess text data for training"""
        # Initialize tokenizer
        self.tokenizer = Tokenizer(num_words=self.max_words, oov_token='<OOV>')
        self.tokenizer.fit_on_texts(texts)
        
        # Convert texts to sequences
        sequences = self.tokenizer.texts_to_sequences(texts)
        
        # Pad sequences
        X = pad_sequences(sequences, maxlen=self.max_length, padding='post', truncating='post')
        
        # Convert labels to numpy array
        y = np.array(labels)
        
        print(f"Preprocessed data shape: {X.shape}")
        print(f"Vocabulary size: {len(self.tokenizer.word_index)}")
        
        return X, y
    
    def build_model(self, num_classes: int) -> Sequential:
        """Build the neural network model"""
        model = Sequential([
            # Embedding layer
            Embedding(input_dim=self.max_words, output_dim=128, input_length=self.max_length),
            
            # LSTM layer for sequence processing
            LSTM(64, return_sequences=True, dropout=0.3, recurrent_dropout=0.3),
            
            # Global max pooling to get fixed-size representation
            GlobalMaxPooling1D(),
            
            # Dense layers with dropout for classification
            Dense(128, activation='relu'),
            Dropout(0.5),
            Dense(64, activation='relu'),
            Dropout(0.3),
            Dense(num_classes, activation='softmax')
        ])
        
        # Compile model
        model.compile(
            optimizer=Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        self.model = model
        return model
    
    def train_model(self, X_train: np.ndarray, y_train: np.ndarray, 
                   X_val: np.ndarray, y_val: np.ndarray, 
                   epochs: int = 50, batch_size: int = 32) -> Dict:
        """Train the model"""
        # Callbacks for training
        callbacks = [
            EarlyStopping(
                monitor='val_loss',
                patience=10,
                restore_best_weights=True,
                verbose=1
            ),
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,
                min_lr=1e-6,
                verbose=1
            )
        ]
        
        # Train the model
        print("Training the model...")
        self.history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1
        )
        
        return self.history.history
    
    def evaluate_model(self, X_test: np.ndarray, y_test: np.ndarray) -> Dict:
        """Evaluate the trained model"""
        if self.model is None:
            raise ValueError("Model not trained yet")
        
        # Make predictions
        y_pred_probs = self.model.predict(X_test)
        y_pred = np.argmax(y_pred_probs, axis=1)
        
        # Calculate metrics
        test_loss, test_accuracy = self.model.evaluate(X_test, y_test, verbose=0)
        
        # Generate classification report
        class_names = list(self.categories.keys())
        report = classification_report(
            y_test, y_pred,
            target_names=class_names,
            output_dict=True
        )
        
        print(f"Test Loss: {test_loss:.4f}")
        print(f"Test Accuracy: {test_accuracy:.4f}")
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=class_names))
        
        # Generate confusion matrix
        cm = confusion_matrix(y_test, y_pred)
        
        return {
            'test_loss': test_loss,
            'test_accuracy': test_accuracy,
            'classification_report': report,
            'confusion_matrix': cm,
            'predictions': y_pred,
            'probabilities': y_pred_probs
        }
    
    def save_model_and_tokenizer(self, model_path: str = 'medical_chatbot_model.h5',
                                tokenizer_path: str = 'tokenizer.json',
                                labels_path: str = 'labels.json'):
        """Save trained model and tokenizer"""
        if self.model is None:
            raise ValueError("Model not trained yet")
        
        # Save model
        self.model.save(model_path)
        print(f"Model saved to {model_path}")
        
        # Save tokenizer
        tokenizer_json = self.tokenizer.to_json()
        with open(tokenizer_path, 'w', encoding='utf-8') as f:
            f.write(tokenizer_json)
        print(f"Tokenizer saved to {tokenizer_path}")
        
        # Save labels
        labels_data = {
            'categories': self.categories,
            'reverse_categories': self.reverse_categories
        }
        with open(labels_path, 'w', encoding='utf-8') as f:
            json.dump(labels_data, f, indent=2)
        print(f"Labels saved to {labels_path}")
    
    def convert_to_tflite(self, tflite_path: str = 'medical_chatbot_model.tflite'):
        """Convert trained model to TensorFlow Lite format"""
        if self.model is None:
            raise ValueError("Model not trained yet")
        
        # Create a representative dataset for quantization
        # This is needed for full integer quantization
        def representative_dataset():
            # Load some sample data for quantization
            with open('medical_chatbot_training_data.json', 'r') as f:
                data = json.load(f)
            
            texts = [item['text'] for item in data['training_data'][:100]]
            sequences = self.tokenizer.texts_to_sequences(texts)
            X = pad_sequences(sequences, maxlen=self.max_length, padding='post')
            
            for i in range(len(X)):
                yield [X[i:i+1].astype(np.float32)]
        
        # Convert to TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        
        # Optimize for mobile
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Set representative dataset for quantization
        converter.representative_dataset = representative_dataset
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8
        converter.inference_output_type = tf.uint8
        
        # Convert model
        tflite_model = converter.convert()
        
        # Save TFLite model
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"TensorFlow Lite model saved to {tflite_path}")
        print(f"Model size: {os.path.getsize(tflite_path) / 1024 / 1024:.2f} MB")
        
        return tflite_path
    
    def plot_training_history(self, save_path: str = 'training_history.png'):
        """Plot training history"""
        if self.history is None:
            raise ValueError("Model not trained yet")
        
        history = self.history.history
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
        
        # Plot accuracy
        ax1.plot(history['accuracy'], label='Training Accuracy')
        ax1.plot(history['val_accuracy'], label='Validation Accuracy')
        ax1.set_title('Model Accuracy')
        ax1.set_xlabel('Epoch')
        ax1.set_ylabel('Accuracy')
        ax1.legend()
        
        # Plot loss
        ax2.plot(history['loss'], label='Training Loss')
        ax2.plot(history['val_loss'], label='Validation Loss')
        ax2.set_title('Model Loss')
        ax2.set_xlabel('Epoch')
        ax2.set_ylabel('Loss')
        ax2.legend()
        
        plt.tight_layout()
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()
        print(f"Training history saved to {save_path}")
    
    def plot_confusion_matrix(self, cm: np.ndarray, save_path: str = 'confusion_matrix.png'):
        """Plot confusion matrix"""
        class_names = list(self.categories.keys())
        
        plt.figure(figsize=(12, 10))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                   xticklabels=class_names, yticklabels=class_names)
        plt.title('Confusion Matrix')
        plt.xlabel('Predicted')
        plt.ylabel('Actual')
        plt.xticks(rotation=45)
        plt.yticks(rotation=0)
        plt.tight_layout()
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()
        print(f"Confusion matrix saved to {save_path}")

def main():
    """Main training function"""
    # Initialize trainer
    trainer = MedicalChatbotTrainer(max_words=5000, max_length=50)
    
    # Load data
    texts, labels = trainer.load_data()
    
    # Split data (80% train, 20% test)
    split_point = int(0.8 * len(texts))
    X_train_texts = texts[:split_point]
    y_train = labels[:split_point]
    X_test_texts = texts[split_point:]
    y_test = labels[split_point:]
    
    # Further split training data for validation (80% train, 20% validation)
    val_split = int(0.8 * len(X_train_texts))
    X_train = X_train_texts[:val_split]
    X_val = X_train_texts[val_split:]
    y_train_final = y_train[:val_split]
    y_val = y_train[val_split:]
    
    print(f"Training samples: {len(X_train)}")
    print(f"Validation samples: {len(X_val)}")
    print(f"Test samples: {len(X_test_texts)}")
    
    # Preprocess data
    X_train_processed, y_train_processed = trainer.preprocess_data(X_train, y_train_final)
    X_val_processed, y_val_processed = trainer.preprocess_data(X_val, y_val)
    X_test_processed, y_test_processed = trainer.preprocess_data(X_test_texts, y_test)
    
    # Build model
    num_classes = len(trainer.categories)
    print(f"Building model for {num_classes} classes...")
    model = trainer.build_model(num_classes)
    print(model.summary())
    
    # Train model
    history = trainer.train_model(
        X_train_processed, y_train_processed,
        X_val_processed, y_val_processed,
        epochs=50, batch_size=16
    )
    
    # Evaluate model
    evaluation_results = trainer.evaluate_model(X_test_processed, y_test_processed)
    
    # Save model and tokenizer
    trainer.save_model_and_tokenizer()
    
    # Convert to TensorFlow Lite
    trainer.convert_to_tflite()
    
    # Plot training history
    trainer.plot_training_history()
    
    # Plot confusion matrix
    trainer.plot_confusion_matrix(evaluation_results['confusion_matrix'])
    
    print("\nTraining completed successfully!")
    print("Generated files:")
    print("- medical_chatbot_model.h5 (Keras model)")
    print("- medical_chatbot_model.tflite (TensorFlow Lite model)")
    print("- tokenizer.json (Text tokenizer)")
    print("- labels.json (Category labels)")
    print("- training_history.png (Training plots)")
    print("- confusion_matrix.png (Confusion matrix)")

if __name__ == "__main__":
    main()