// Video Modal Functionality
const videoBtn = document.getElementById("videoBtn")
const videoModal = document.getElementById("videoModal")
const videoClose = document.querySelector(".video-close")
const videoFrame = document.getElementById("videoFrame")

// Replace with your actual YouTube video ID
const YOUTUBE_VIDEO_ID = "dQw4w9WgXcQ" // Replace this with your actual video ID
const YOUTUBE_EMBED_URL = `https://www.youtube.com/embed/${YOUTUBE_VIDEO_ID}?autoplay=1`

// videoBtn.addEventListener("click", () => {
//   videoModal.style.display = "block"
//   videoFrame.src = YOUTUBE_EMBED_URL
//   document.body.style.overflow = "hidden"
// })

videoClose.addEventListener("click", closeVideoModal)

videoModal.addEventListener("click", (e) => {
  if (e.target === videoModal) {
    closeVideoModal()
  }
})

function closeVideoModal() {
  videoModal.style.display = "none"
  videoFrame.src = ""
  document.body.style.overflow = "auto"
}

// Download Button Functionality
const downloadBtns = document.querySelectorAll("#downloadBtn, #downloadBtnLarge, #navDownloadBtn")

downloadBtns.forEach((btn) => {
  btn.addEventListener("click", (e) => {
    e.preventDefault()

    const downloadUrl = "https://github.com/khaledbourghida/TokenTrove/releases/download/TokenTrove/app-release.apk"

    // Show download instructions for Android users
    const userConfirmed = confirm(
      currentLanguage === "ar"
        ? "مستعد لتحميل تطبيق جواهر فري فاير؟\n\n" +
            "📱 لمستخدمي الأندرويد:\n" +
            "1. فعل 'التثبيت من مصادر غير معروفة' في الإعدادات\n" +
            "2. سيبدأ التحميل تلقائياً\n" +
            "3. ثبت ملف APK\n\n" +
            "اضغط موافق لمتابعة التحميل."
        : "Ready to download Free Fire Diamonds app?\n\n" +
            "📱 For Android users:\n" +
            "1. Enable 'Install from unknown sources' in Settings\n" +
            "2. Download will start automatically\n" +
            "3. Install the APK file\n\n" +
            "Click OK to continue download.",
    )

    if (userConfirmed) {
      window.open(downloadUrl, "_blank")

      // Show success message
      setTimeout(() => {
        alert(
          currentLanguage === "ar"
            ? "بدأ التحميل! 🎉\n\nإذا لم يبدأ التحميل تلقائياً، يرجى التحقق من إعدادات التحميل في المتصفح."
            : "Download started! 🎉\n\nIf download doesn't start automatically, please check your browser's download settings.",
        )
      }, 500)
    }
  })
})

// Smooth Scrolling for Navigation Links
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

// Header Background on Scroll
window.addEventListener("scroll", () => {
  const header = document.querySelector(".header")
  if (window.scrollY > 100) {
    header.style.background = "rgba(28, 28, 28, 0.98)"
  } else {
    header.style.background = "rgba(28, 28, 28, 0.95)"
  }
})

// Intersection Observer for Animations
const observerOptions = {
  threshold: 0.1,
  rootMargin: "0px 0px -50px 0px",
}

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.style.opacity = "1"
      entry.target.style.transform = "translateY(0)"
    }
  })
}, observerOptions)

// Observe elements for animation
document.querySelectorAll(".feature-card, .step, .trust-item").forEach((el) => {
  el.style.opacity = "0"
  el.style.transform = "translateY(30px)"
  el.style.transition = "opacity 0.6s ease, transform 0.6s ease"
  observer.observe(el)
})

// Language translations object
const translations = {
  en: {
    "nav-features": "Features",
    "nav-how-it-works": "How It Works",
    "nav-download": "Download Now",
    "lang-toggle": "EN",
    "hero-earn": "Earn",
    "hero-free": "FREE",
    "hero-diamonds": "Free Fire Diamonds",
    "hero-subtitle": "Just by Watching Ads!",
    "hero-description":
      "The only legitimate app to earn Free Fire diamonds. Watch ads, join competitions, participate in leagues, and get real rewards delivered to your account.",
    "download-app": "Download App",
    "watch-demo": "Watch Demo",
    "trust-users": "Happy Users",
    "trust-diamonds": "Diamonds Delivered",
    "trust-rating": "User Rating",
    "features-title": "App Features",
    "feature-watch-title": "Watch Ads & Earn",
    "feature-watch-desc":
      "Watch short video ads and earn tokens instantly. 60-second cooldown between ads for fair play.",
    "feature-exchange-title": "Exchange for Diamonds",
    "feature-exchange-desc":
      "Convert your tokens to Free Fire diamonds. Multiple packages available from 100 to 6900 diamonds.",
    "feature-competition-title": "Weekly Competitions",
    "feature-competition-desc": "Compete with other users! Top 3 ad watchers each week win bonus diamond rewards.",
    "feature-leagues-title": "Free Fire Leagues",
    "feature-leagues-desc":
      "Join battle royale tournaments. Solo, team, and clash squad modes with diamond prizes for winners.",
    "feature-codes-title": "Free Fire Code Generator",
    "feature-codes-desc": "Generate up to 30 Free Fire codes daily. Bonus codes available for active users.",
    "feature-safe-title": "100% Safe & Secure",
    "feature-safe-desc": "Your account is completely safe. We never ask for passwords or sensitive information.",
    "how-it-works-title": "How It Works",
    "step1-title": "Download & Register",
    "step1-desc": "Download the app and create your free account in seconds.",
    "step2-title": "Watch Ads",
    "step2-desc": "Watch short video ads to earn tokens. Each ad gives you 1 token.",
    "step3-title": "Exchange Tokens",
    "step3-desc": "Convert your tokens to Free Fire diamonds through our exchange system.",
    "step4-title": "Get Diamonds",
    "step4-desc": "Receive your Free Fire diamonds directly to your game account within 24 hours.",
    "download-title": "Ready to Start Earning?",
    "download-description": "Join thousands of Free Fire players who are already earning free diamonds!",
    "download-now": "Download Now - It's Free!",
    "download-note": "Available for Android devices. iOS version coming soon!",
  },
  ar: {
    "nav-features": "المميزات",
    "nav-how-it-works": "كيف يعمل",
    "nav-download": "تحميل الآن",
    "lang-toggle": "AR",
    "hero-earn": "اكسب",
    "hero-free": "مجاناً",
    "hero-diamonds": "جواهر فري فاير",
    "hero-subtitle": "فقط بمشاهدة الإعلانات!",
    "hero-description":
      "التطبيق الوحيد الشرعي لكسب جواهر فري فاير. شاهد الإعلانات، انضم للمسابقات، شارك في البطولات، واحصل على مكافآت حقيقية.",
    "download-app": "تحميل التطبيق",
    "watch-demo": "مشاهدة العرض",
    "trust-users": "مستخدم سعيد",
    "trust-diamonds": "جوهرة مُسلمة",
    "trust-rating": "تقييم المستخدمين",
    "features-title": "مميزات التطبيق",
    "feature-watch-title": "شاهد الإعلانات واكسب",
    "feature-watch-desc": "شاهد إعلانات فيديو قصيرة واكسب الرموز فوراً. فترة انتظار 60 ثانية بين الإعلانات للعب العادل.",
    "feature-exchange-title": "استبدل بالجواهر",
    "feature-exchange-desc": "حول رموزك إلى جواهر فري فاير. حزم متعددة متاحة من 100 إلى 6900 جوهرة.",
    "feature-competition-title": "مسابقات أسبوعية",
    "feature-competition-desc":
      "تنافس مع المستخدمين الآخرين! أفضل 3 مشاهدين للإعلانات كل أسبوع يفوزون بمكافآت جواهر إضافية.",
    "feature-leagues-title": "بطولات فري فاير",
    "feature-leagues-desc": "انضم لبطولات الباتل رويال. أنماط فردية وجماعية وكلاش سكواد مع جوائز جواهر للفائزين.",
    "feature-codes-title": "مولد أكواد فري فاير",
    "feature-codes-desc": "أنتج حتى 30 كود فري فاير يومياً. أكواد إضافية متاحة للمستخدمين النشطين.",
    "feature-safe-title": "100% آمن ومحمي",
    "feature-safe-desc": "حسابك آمن تماماً. نحن لا نطلب كلمات المرور أو المعلومات الحساسة أبداً.",
    "how-it-works-title": "كيف يعمل",
    "step1-title": "حمل وسجل",
    "step1-desc": "حمل التطبيق وأنشئ حسابك المجاني في ثوانٍ.",
    "step2-title": "شاهد الإعلانات",
    "step2-desc": "شاهد إعلانات فيديو قصيرة لكسب الرموز. كل إعلان يعطيك رمز واحد.",
    "step3-title": "استبدل الرموز",
    "step3-desc": "حول رموزك إلى جواهر فري فاير من خلال نظام الاستبدال.",
    "step4-title": "احصل على الجواهر",
    "step4-desc": "استلم جواهر فري فاير مباشرة في حساب اللعبة خلال 24 ساعة.",
    "download-title": "مستعد لبدء الكسب؟",
    "download-description": "انضم لآلاف لاعبي فري فاير الذين يكسبون الجواهر المجانية بالفعل!",
    "download-now": "تحميل الآن - مجاناً!",
    "download-note": "متاح لأجهزة الأندرويد. إصدار iOS قريباً!",
  },
}

let currentLanguage = "en"

function translatePage(language) {
  const elements = document.querySelectorAll("[data-translate]")
  elements.forEach((element) => {
    const key = element.getAttribute("data-translate")
    if (translations[language] && translations[language][key]) {
      element.textContent = translations[language][key]
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

  if (language === "ar" && window.innerWidth <= 768) {
    // Force reflow to fix mobile Arabic layout issues
    document.body.style.display = "none"
    document.body.offsetHeight // Trigger reflow
    document.body.style.display = ""

    // Ensure proper mobile layout for Arabic
    setTimeout(() => {
      const heroContent = document.querySelector(".hero-content")
      const heroActions = document.querySelector(".hero-actions")
      const trustIndicators = document.querySelector(".trust-indicators")

      if (heroContent) heroContent.style.textAlign = "center"
      if (heroActions) heroActions.style.flexDirection = "column"
      if (trustIndicators) trustIndicators.style.justifyContent = "center"
    }, 100)
  }
}

// Language toggle functionality
document.getElementById("languageToggle").addEventListener("click", () => {
  currentLanguage = currentLanguage === "en" ? "ar" : "en"
  translatePage(currentLanguage)
  localStorage.setItem("preferred-language", currentLanguage)
})

// Load saved language preference
document.addEventListener("DOMContentLoaded", () => {
  const savedLanguage = localStorage.getItem("preferred-language")
  if (savedLanguage && savedLanguage !== "en") {
    currentLanguage = savedLanguage
    translatePage(currentLanguage)
  }
})

// Console log for debugging
console.log("Free Fire Diamonds Landing Page Loaded Successfully! 💎")
