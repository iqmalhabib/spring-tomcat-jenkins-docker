package com.example.tomcat_jenkins.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HealthController {

    @GetMapping({"/", "/health"})
    public String health(Model model) {
        model.addAttribute("status", "UP");
        model.addAttribute("appName", "Spring Demo App");
        model.addAttribute("version", "1.0.0");
        model.addAttribute("timestamp", java.time.LocalDateTime.now().toString());
        return "health"; // Thymeleaf will look for health.html
    }
}