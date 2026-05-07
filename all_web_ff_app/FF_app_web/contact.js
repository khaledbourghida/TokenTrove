// Language translations for Contact page
const contactTranslations = {
  en: {
    "lang-toggle": "EN",
    "contact-title": "Contact Support",
    "contact-description": "Need help with the app? Have questions or issues? We're here to help you 24/7!",
    "contact-info-title": "Get in Touch",
    "contact-info-desc":
      "Fill out the form and we'll get back to you within 24 hours. For urgent issues, please include your Free Fire ID and detailed description.",
    "contact-feature1-title": "Quick Response",
    "contact-feature1-desc": "We respond within 24 hours",
    "contact-feature2-title": "Secure & Private",
    "contact-feature2-desc": "Your information is safe with us",
    "contact-feature3-title": "Expert Support",
    "contact-feature3-desc": "Our team knows the app inside out",
    "form-name": "Your Name",
    "form-email": "Email Address",
    "form-ffid": "Free Fire ID (Optional)",
    "form-issue-type": "Issue Type",
    "form-select-option": "Select an issue type",
    "form-option-download": "Download/Installation Problem",
    "form-option-tokens": "Tokens/Ads Issue",
    "form-option-diamonds": "Diamond Exchange Problem",
    "form-option-account": "Account Issue",
    "form-option-competition": "Competition/League Issue",
    "form-option-other": "Other",
    "form-subject": "Subject",
    "form-message": "Detailed Message",
    "form-submit": "Send Message",
    "form-sending": "Sending...",
    "success-title": "Message Sent Successfully!",
    "success-text":
      "Thank you for contacting us. We've received your message and will respond within 24 hours. You should also receive a confirmation email shortly.",
    "success-button": "Send Another Message",
    "faq-link-title": "Looking for Quick Answers?",
    "faq-link-desc": "Check our FAQ page for instant solutions to common problems.",
    "faq-link-button": "View FAQ",
  },
  ar: {
    "lang-toggle": "AR",
    "contact-title": "اتصل بالدعم",
    "contact-description": "تحتاج مساعدة مع التطبيق؟ لديك أسئلة أو مشاكل؟ نحن هنا لمساعدتك 24/7!",
    "contact-info-title": "تواصل معنا",
    "contact-info-desc": "املأ النموذج وسنرد عليك خلال 24 ساعة. للمشاكل العاجلة، يرجى تضمين معرف فري فاير ووصف مفصل.",
    "contact-feature1-title": "رد سريع",
    "contact-feature1-desc": "نرد خلال 24 ساعة",
    "contact-feature2-title": "آمن وخاص",
    "contact-feature2-desc": "معلوماتك آمنة معنا",
    "contact-feature3-title": "دعم خبير",
    "contact-feature3-desc": "فريقنا يعرف التطبيق من الداخل والخارج",
    "form-name": "اسمك",
    "form-email": "عنوان البريد الإلكتروني",
    "form-ffid": "معرف فري فاير (اختياري)",
    "form-issue-type": "نوع المشكلة",
    "form-select-option": "اختر نوع المشكلة",
    "form-option-download": "مشكلة تحميل/تثبيت",
    "form-option-tokens": "مشكلة رموز/إعلانات",
    "form-option-diamonds": "مشكلة استبدال جواهر",
    "form-option-account": "مشكلة حساب",
    "form-option-competition": "مشكلة مسابقة/بطولة",
    "form-option-other": "أخرى",
    "form-subject": "الموضوع",
    "form-message": "رسالة مفصلة",
    "form-submit": "إرسال الرسالة",
    "form-sending": "جاري الإرسال...",
    "success-title": "تم إرسال الرسالة بنجاح!",
    "success-text": "شكراً لتواصلك معنا. لقد استلمنا رسالتك وسنرد خلال 24 ساعة. ستستلم أيضاً بريد تأكيد قريباً.",
    "success-button": "إرسال رسالة أخرى",
    "faq-link-title": "تبحث عن إجابات سريعة؟",
    "faq-link-desc": "تحقق من صفحة الأسئلة الشائعة للحصول على حلول فورية للمشاكل الشائعة.",
    "faq-link-button": "عرض الأسئلة الشائعة",
  },
}

let currentLanguage = "en"

function translateContactPage(language) {
  const elements = document.querySelectorAll("[data-translate]")
  elements.forEach((element) => {
    const key = element.getAttribute("data-translate")
    if (contactTranslations[language] && contactTranslations[language][key]) {
      if (element.tagName === "INPUT" || element.tagName === "TEXTAREA") {
        element.placeholder = contactTranslations[language][key]
      } else if (element.tagName === "OPTION") {
        element.textContent = contactTranslations[language][key]
      } else {
        element.innerHTML = contactTranslations[language][key]
      }
    }
  })

  // Update HTML lang attribute and direction
  document.documentElement.lang = language
  document.documentElement.dir = language === "ar" ? "rtl" : "ltr"

  // Update language toggle text
  const langToggle = document.querySelector(".lang-text")
  if (langToggle) {
    langToggle.textContent = language === "en" ? "AR" : "EN"
  }
}

// Language toggle functionality
document.getElementById("languageToggle").addEventListener("click", () => {
  currentLanguage = currentLanguage === "en" ? "ar" : "en"
  translateContactPage(currentLanguage)
  localStorage.setItem("preferred-language", currentLanguage)
})

// Load saved language preference
document.addEventListener("DOMContentLoaded", () => {
  const savedLanguage = localStorage.getItem("preferred-language")
  if (savedLanguage && savedLanguage !== "en") {
    currentLanguage = savedLanguage
    translateContactPage(currentLanguage)
  }
})

// Contact form functionality
const contactForm = document.getElementById("contactForm")
const submitBtn = document.getElementById("submitBtn")
const successMessage = document.getElementById("successMessage")

contactForm.addEventListener("submit", async (e) => {
  e.preventDefault()

  // Show loading state
  const submitText = submitBtn.querySelector(".submit-text")
  const submitLoading = submitBtn.querySelector(".submit-loading")

  submitText.style.display = "none"
  submitLoading.style.display = "inline"
  submitBtn.disabled = true

  // Get form data
  const formData = new FormData(contactForm)
  const data = {
    name: formData.get("name"),
    email: formData.get("email"),
    freeFireId: formData.get("freeFireId") || "Not provided",
    issueType: formData.get("issueType"),
    subject: formData.get("subject"),
    message: formData.get("message"),
    timestamp: new Date().toISOString(),
    language: currentLanguage,
  }

  try {
    // Send email using EmailJS or similar service
    // For demo purposes, we'll simulate the email sending
    await sendContactEmail(data)

    // Show success message
    contactForm.style.display = "none"
    successMessage.style.display = "block"
  } catch (error) {
    console.error("Error sending email:", error)
    alert(
      currentLanguage === "ar"
        ? "حدث خطأ في إرسال الرسالة. يرجى المحاولة مرة أخرى."
        : "Error sending message. Please try again.",
    )
  } finally {
    // Reset button state
    submitText.style.display = "inline"
    submitLoading.style.display = "none"
    submitBtn.disabled = false
  }
})

async function sendContactEmail(data) {
  try {
    // Send email using EmailJS with your Gmail configuration
    const emailParams = {
      from_name: data.name,
      from_email: data.email,
      to_email: "walidbourghida99@gmail.com",
      subject: `Contact Form: ${data.subject}`,
      message: formatContactMessage(data),
      reply_to: data.email,
    }

    // Send main contact email to your Gmail
    await window.emailjs.send("service_gmail", "template_contact", emailParams, "jqrmwogoteqvtjdy")

    // Send auto-reply confirmation to user
    const confirmationParams = {
      to_email: data.email,
      to_name: data.name,
      subject: currentLanguage === "ar" ? "تأكيد استلام رسالتك" : "Message Received Confirmation",
      message: getConfirmationMessage(data.name, currentLanguage),
    }

    await window.emailjs.send("service_gmail", "template_confirmation", confirmationParams, "jqrmwogoteqvtjdy")

    return Promise.resolve()
  } catch (error) {
    console.error("Email sending failed:", error)
    throw error
  }
}

function formatContactMessage(data) {
  const arabicMessage = `
رسالة جديدة من نموذج الاتصال 📧

الاسم: ${data.name}
البريد الإلكتروني: ${data.email}
معرف فري فاير: ${data.freeFireId}
نوع المشكلة: ${data.issueType}
الموضوع: ${data.subject}
اللغة: ${data.language === "ar" ? "العربية" : "الإنجليزية"}
التاريخ: ${new Date(data.timestamp).toLocaleString("ar-SA")}

الرسالة:
${data.message}

---
  `

  const englishMessage = `
New Contact Form Message 📧

Name: ${data.name}
Email: ${data.email}
Free Fire ID: ${data.freeFireId}
Issue Type: ${data.issueType}
Subject: ${data.subject}
Language: ${data.language === "ar" ? "Arabic" : "English"}
Date: ${new Date(data.timestamp).toLocaleString("en-US")}

Message:
${data.message}
  `

  return arabicMessage + englishMessage
}

function getConfirmationMessage(userName, language) {
  if (language === "ar") {
    return `
مرحباً ${userName} 👋

شكراً لتواصلك معنا! 🎉

لقد استلمنا رسالتك بنجاح وسنقوم بالرد عليك خلال 24 ساعة.

📌 فريق الدعم الفني لتطبيق جواهر فري فاير

---

Hello ${userName} 👋

Thank you for contacting us! 🎉

We have successfully received your message and will respond within 24 hours.

📌 Free Fire Diamonds App Support Team
    `
  } else {
    return `
Hello ${userName} 👋

Thank you for contacting us! 🎉

We have successfully received your message and will respond within 24 hours.

📌 Free Fire Diamonds App Support Team

---

مرحباً ${userName} 👋

شكراً لتواصلك معنا! 🎉

لقد استلمنا رسالتك بنجاح وسنقوم بالرد عليك خلال 24 ساعة.

📌 فريق الدعم الفني لتطبيق جواهر فري فاير
    `
  }
}

// Reset form function
function resetForm() {
  contactForm.reset()
  contactForm.style.display = "flex"
  successMessage.style.display = "none"
}

// Make resetForm available globally
window.resetForm = resetForm

console.log("Contact Page Loaded Successfully! 📧")
