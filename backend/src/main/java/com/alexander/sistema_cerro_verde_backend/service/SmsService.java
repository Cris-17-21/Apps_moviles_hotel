package com.alexander.sistema_cerro_verde_backend.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;

@Service
public class SmsService {

  @Value("${twilio.account-sid}")
  private String accountSid;

  @Value("${twilio.auth-token}")
  private String authToken;

  @Value("${twilio.phone-number}")
  private String phoneNumber;

  @Value("${twilio.messaging-service-sid}")
  private String messagingServiceSid;

  @PostConstruct
  public void init() {
    if (accountSid != null && !accountSid.isEmpty() && authToken != null && !authToken.isEmpty()) {
      Twilio.init(accountSid, authToken);
    }
  }

  public void enviarSms(String mensaje) {
    if (accountSid == null || accountSid.isEmpty()) {
      System.out.println("SMS no configurado — saltando envío a: " + mensaje);
      return;
    }
    Message message = Message.creator(
        new PhoneNumber(phoneNumber),
        messagingServiceSid,
        mensaje
    ).create();
    System.out.println("SMS enviado: " + message.getSid());
  }
}

