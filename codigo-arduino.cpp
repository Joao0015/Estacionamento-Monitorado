#include <WiFi.h>
#include <WebServer.h>

// --- CONFIGURAÇÃO DO SEU WIFI ---
const char* ssid = "wifi";
const char* password = "panquecadefrango";

WebServer server(80);

// Pinos baseados na sua foto (D13 energia, D12 sinal)
const int pinoEnergia = 13; 
const int pinoBotao = 12;

void handleRoot() {
  // O "IF" que responde ao App Flutter
  if (digitalRead(pinoBotao) == HIGH) {
    server.send(200, "text/plain", "ocupada");
  } else {
    server.send(200, "text/plain", "livre");
  }
}

void setup() {
  Serial.begin(115200);
  
  pinMode(pinoEnergia, OUTPUT);
  digitalWrite(pinoEnergia, HIGH); // Liga a energia do botão
  pinMode(pinoBotao, INPUT);

  // Conectando no Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  // AQUI VAI APARECER O IP QUE VOCÊ PRECISA!
  Serial.println("\n--- CONECTADO! ---");
  Serial.print("IP DO ESP32: ");
  Serial.println(WiFi.localIP()); 

  server.on("/", handleRoot);
  server.begin();
}

void loop() {
  server.handleClient(); // Mantém o servidor vivo
  
  // O "IF" para você ver no Serial Monitor também
  if (digitalRead(pinoBotao) == HIGH) {
    Serial.println("STATUS: [ OCUPADO ]");
  } else {
    Serial.println("STATUS: [ LIVRE ]");
  }
  delay(500); 
}
