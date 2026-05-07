// Language translations for FAQ page
const faqTranslations = {
  en: {
    "lang-toggle": "EN",
    "faq-title": "Common Errors & Solutions",
    "faq-description": "Find quick solutions to the most common issues with our Free Fire diamonds app.",
    "faq-download-title": "Download Issues",
    "faq-q1": "App won't download or install",
    "faq-a1":
      '1. Enable "Install from unknown sources" in Android Settings > Security<br>2. Clear browser cache and try downloading again<br>3. Make sure you have enough storage space (at least 100MB)<br>4. Try downloading using a different browser',
    "faq-q2": '"App not installed" error message',
    "faq-a2":
      '1. Uninstall any previous version of the app<br>2. Restart your device<br>3. Download the latest APK file<br>4. Install with "Install from unknown sources" enabled',
    "faq-token-title": "Token & Ads Issues",
    "faq-q3": "Ads not loading or showing",
    "faq-a3":
      "1. Check your internet connection<br>2. Close and reopen the app<br>3. Wait for the 60-second cooldown to finish<br>4. Try switching between WiFi and mobile data<br>5. Restart your device if problem persists",
    "faq-q4": "Tokens not being added after watching ads",
    "faq-a4":
      "1. Make sure you watch the complete ad (don't skip)<br>2. Wait a few seconds after the ad finishes<br>3. Check your internet connection<br>4. Force close and reopen the app<br>5. Contact support if tokens still missing after 5 minutes",
    "faq-q5": '"No ads available" message',
    "faq-a5":
      "1. This is normal - ads refresh every few hours<br>2. Try again in 30-60 minutes<br>3. Make sure your device date/time is correct<br>4. Clear app cache in Android Settings > Apps > FF Diamonds > Storage",
    "faq-diamond-title": "Diamond Exchange Issues",
    "faq-q6": "Diamond request not processed",
    "faq-a6":
      "1. Diamond requests are processed within 24 hours<br>2. Make sure you provided correct Free Fire ID<br>3. Check if you have enough tokens for the exchange<br>4. Contact support with your request ID if delayed beyond 24 hours",
    "faq-q7": "Wrong Free Fire ID entered",
    "faq-a7":
      "1. Contact support immediately with correct ID<br>2. Provide your request ID and correct Free Fire ID<br>3. We can update the ID before processing<br>4. Double-check your ID before submitting future requests",
    "faq-account-title": "Account Issues",
    "faq-q8": "Can't login or register",
    "faq-a8":
      "1. Check your internet connection<br>2. Make sure you're using a valid email address<br>3. Try using a different email provider<br>4. Clear app data and try registering again<br>5. Contact support if problem continues",
    "faq-q9": "Lost tokens or progress",
    "faq-a9":
      "1. Make sure you're logged into the same account<br>2. Check your internet connection<br>3. Force close and reopen the app<br>4. Wait a few minutes for data to sync<br>5. Contact support with your account email if data doesn't restore",
    "faq-competition-title": "Competition & League Issues",
    "faq-q10": "Not showing on leaderboard",
    "faq-a10":
      "1. Leaderboard updates every hour<br>2. Make sure you've watched at least 5 ads<br>3. Check if competition is currently active<br>4. Refresh the leaderboard by pulling down<br>5. Contact support if still not showing after 2 hours",
    "faq-q11": "Didn't receive competition prize",
    "faq-a11":
      "1. Prizes are distributed within 48 hours after competition ends<br>2. Check your account balance for added diamonds<br>3. Make sure you finished in top 3 positions<br>4. Contact support with screenshot of your final position",
    "faq-support-title": "Still Need Help?",
    "faq-support-desc": "Can't find the solution to your problem? Our support team is here to help!",
    "faq-contact-button": "Contact Support",
  },
  ar: {
    "lang-toggle": "AR",
    "faq-title": "الأخطاء الشائعة والحلول",
    "faq-description": "اعثر على حلول سريعة لأكثر المشاكل شيوعاً في تطبيق جواهر فري فاير.",
    "faq-download-title": "مشاكل التحميل",
    "faq-q1": "التطبيق لا يتم تحميله أو تثبيته",
    "faq-a1":
      '1. فعل "التثبيت من مصادر غير معروفة" في إعدادات الأندرويد > الأمان<br>2. امسح ذاكرة التخزين المؤقت للمتصفح وحاول التحميل مرة أخرى<br>3. تأكد من وجود مساحة تخزين كافية (100 ميجابايت على الأقل)<br>4. جرب التحميل باستخدام متصفح مختلف',
    "faq-q2": 'رسالة خطأ "التطبيق غير مثبت"',
    "faq-a2":
      '1. احذف أي إصدار سابق من التطبيق<br>2. أعد تشغيل جهازك<br>3. حمل أحدث ملف APK<br>4. ثبت مع تفعيل "التثبيت من مصادر غير معروفة"',
    "faq-token-title": "مشاكل الرموز والإعلانات",
    "faq-q3": "الإعلانات لا تحمل أو تظهر",
    "faq-a3":
      "1. تحقق من اتصال الإنترنت<br>2. أغلق التطبيق وأعد فتحه<br>3. انتظر انتهاء فترة الانتظار 60 ثانية<br>4. جرب التبديل بين الواي فاي وبيانات الهاتف<br>5. أعد تشغيل جهازك إذا استمرت المشكلة",
    "faq-q4": "الرموز لا تضاف بعد مشاهدة الإعلانات",
    "faq-a4":
      "1. تأكد من مشاهدة الإعلان كاملاً (لا تتخطاه)<br>2. انتظر بضع ثوانٍ بعد انتهاء الإعلان<br>3. تحقق من اتصال الإنترنت<br>4. أغلق التطبيق بالقوة وأعد فتحه<br>5. اتصل بالدعم إذا كانت الرموز ما زالت مفقودة بعد 5 دقائق",
    "faq-q5": 'رسالة "لا توجد إعلانات متاحة"',
    "faq-a5":
      "1. هذا طبيعي - الإعلانات تتجدد كل بضع ساعات<br>2. جرب مرة أخرى خلال 30-60 دقيقة<br>3. تأكد من صحة تاريخ ووقت جهازك<br>4. امسح ذاكرة التطبيق المؤقتة في إعدادات الأندرويد > التطبيقات > FF Diamonds > التخزين",
    "faq-diamond-title": "مشاكل استبدال الجواهر",
    "faq-q6": "طلب الجواهر لم يتم معالجته",
    "faq-a6":
      "1. طلبات الجواهر تتم معالجتها خلال 24 ساعة<br>2. تأكد من تقديم معرف فري فاير الصحيح<br>3. تحقق من وجود رموز كافية للاستبدال<br>4. اتصل بالدعم مع رقم طلبك إذا تأخر أكثر من 24 ساعة",
    "faq-q7": "تم إدخال معرف فري فاير خاطئ",
    "faq-a7":
      "1. اتصل بالدعم فوراً مع المعرف الصحيح<br>2. قدم رقم طلبك ومعرف فري فاير الصحيح<br>3. يمكننا تحديث المعرف قبل المعالجة<br>4. تحقق مرتين من معرفك قبل تقديم الطلبات المستقبلية",
    "faq-account-title": "مشاكل الحساب",
    "faq-q8": "لا يمكن تسجيل الدخول أو التسجيل",
    "faq-a8":
      "1. تحقق من اتصال الإنترنت<br>2. تأكد من استخدام عنوان بريد إلكتروني صالح<br>3. جرب استخدام مزود بريد إلكتروني مختلف<br>4. امسح بيانات التطبيق وحاول التسجيل مرة أخرى<br>5. اتصل بالدعم إذا استمرت المشكلة",
    "faq-q9": "فقدان الرموز أو التقدم",
    "faq-a9":
      "1. تأكد من تسجيل الدخول لنفس الحساب<br>2. تحقق من اتصال الإنترنت<br>3. أغلق التطبيق بالقوة وأعد فتحه<br>4. انتظر بضع دقائق لمزامنة البيانات<br>5. اتصل بالدعم مع بريد حسابك الإلكتروني إذا لم تستعد البيانات",
    "faq-competition-title": "مشاكل المسابقات والبطولات",
    "faq-q10": "لا أظهر في لوحة المتصدرين",
    "faq-a10":
      "1. لوحة المتصدرين تتحدث كل ساعة<br>2. تأكد من مشاهدة 5 إعلانات على الأقل<br>3. تحقق من كون المسابقة نشطة حالياً<br>4. حدث لوحة المتصدرين بالسحب للأسفل<br>5. اتصل بالدعم إذا لم تظهر بعد ساعتين",
    "faq-q11": "لم أستلم جائزة المسابقة",
    "faq-a11":
      "1. الجوائز توزع خلال 48 ساعة بعد انتهاء المسابقة<br>2. تحقق من رصيد حسابك للجواهر المضافة<br>3. تأكد من إنهائك في المراكز الثلاثة الأولى<br>4. اتصل بالدعم مع لقطة شاشة لمركزك النهائي",
    "faq-support-title": "ما زلت تحتاج مساعدة؟",
    "faq-support-desc": "لا تجد الحل لمشكلتك؟ فريق الدعم هنا لمساعدتك!",
    "faq-contact-button": "اتصل بالدعم",
  },
}

let currentLanguage = "en"

function translateFaqPage(language) {
  const elements = document.querySelectorAll("[data-translate]")
  elements.forEach((element) => {
    const key = element.getAttribute("data-translate")
    if (faqTranslations[language] && faqTranslations[language][key]) {
      if (element.tagName === "INPUT" || element.tagName === "TEXTAREA") {
        element.placeholder = faqTranslations[language][key]
      } else {
        element.innerHTML = faqTranslations[language][key]
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
  translateFaqPage(currentLanguage)
  localStorage.setItem("preferred-language", currentLanguage)
})

// Load saved language preference
document.addEventListener("DOMContentLoaded", () => {
  const savedLanguage = localStorage.getItem("preferred-language")
  if (savedLanguage && savedLanguage !== "en") {
    currentLanguage = savedLanguage
    translateFaqPage(currentLanguage)
  }
})

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener("click", function (e) {
    e.preventDefault()
    const target = document.querySelector(this.getAttribute("href"))
    if (target) {
      target.scrollIntoView({
        behavior: "smooth",
        block: "start",
      })
    }
  })
})

console.log("FAQ Page Loaded Successfully! ❓")
