// Translations
const translations = {
  en: {
    processingTitle: "Processing Your Reward...",
    processingDescription: "Please wait while we claim your tokens",
    successTitle: "Proccess Completed Successfully!",
    successDescription: "Redirect to officail app page",
    tokenLabel: "Visitor Added",
    errorTitle: "Claim Failed",
    alreadyClaimedError: "You have already claimed your reward today",
    networkError: "Network error. Please check your connection and try again.",
    serverError: "Server error. Please try again later.",
    unknownError: "Something went wrong. Please try again.",
    retryButton: "Try Again",
  },
  ar: {
    processingTitle: "جاري معالجة مكافأتك...",
    processingDescription: "يرجى الانتظار بينما نقوم بإضافة الرموز المميزة",
    successTitle: "تمت العملية بنجاح!",
    successDescription: "إعادة التوجيه إلى صفحة التطبيق الرسمية",
    tokenLabel: "زيارة مضافة",
    errorTitle: "فشل في الاستلام",
    alreadyClaimedError: "لقد استلمت مكافأتك اليوم بالفعل",
    networkError: "خطأ في الشبكة. يرجى التحقق من اتصالك والمحاولة مرة أخرى.",
    serverError: "خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.",
    unknownError: "حدث خطأ ما. يرجى المحاولة مرة أخرى.",
    retryButton: "حاول مرة أخرى",
  },
}

// Current language
let currentLang = "en"

// DOM elements
const loadingState = document.getElementById("loading-state")
const successState = document.getElementById("success-state")
const errorState = document.getElementById("error-state")
const retryButton = document.getElementById("retry-button")
const langEnBtn = document.getElementById("lang-en")
const langArBtn = document.getElementById("lang-ar")

// Get URL parameters
function getUrlParams() {
  const urlParams = new URLSearchParams(window.location.search)
  return {
    slug: urlParams.get("slug"),
  }
}

// Update text content based on current language
function updateText() {
  const t = translations[currentLang]

  // Update loading state
  document.getElementById("loading-title").textContent = t.processingTitle
  document.getElementById("loading-description").textContent = t.processingDescription

  // Update success state
  document.getElementById("success-title").textContent = t.successTitle
  document.getElementById("success-description").textContent = t.successDescription
  document.getElementById("token-label").textContent = t.tokenLabel

  // Update error state
  document.getElementById("error-title").textContent = t.errorTitle
  document.getElementById("retry-button").textContent = t.retryButton

  // Update HTML attributes for RTL
  const html = document.documentElement
  if (currentLang === "ar") {
    html.setAttribute("lang", "ar")
    html.setAttribute("dir", "rtl")
  } else {
    html.setAttribute("lang", "en")
    html.setAttribute("dir", "ltr")
  }
}

// Show specific state
function showState(state) {
  loadingState.classList.add("hidden")
  successState.classList.add("hidden")
  errorState.classList.add("hidden")

  state.classList.remove("hidden")
}

// Show error with specific message
function showError(message) {
  document.getElementById("error-message").textContent = message
  showState(errorState)
}

// Claim reward function
async function claimReward() {
  var { slug } = getUrlParams()

  // Validate parameters
  if (!slug) {
    showError(translations[currentLang].unknownError)
    return
  }

  slug = slug.split('.')[0];

  showState(loadingState)

  try {
    console.log("[v0] Starting reward claim process", {slug})

    const response = await fetch(`https://tokentrove-server.onrender.com/${slug}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    })

    console.log("[v0] API response status:", response.status)

    const data = await response.json()
    console.log("[v0] API response data:", data)

    if (response.ok) {
      // Success
      showState(successState)
      window.location.replace("https://comforting-torte-626735.netlify.app/");
    } else {
      // Handle specific error messages
      let errorMessage = translations[currentLang].unknownError

      if (data.message) {
        if (data.message.toLowerCase().includes("already claimed") || data.message.toLowerCase().includes("already")) {
          errorMessage = translations[currentLang].alreadyClaimedError
        } else {
          errorMessage = data.message
        }
      }

      showError(errorMessage)
    }
  } catch (error) {
    console.error("[v0] Network error:", error)

    // Handle network errors
    if (error.name === "TypeError" && error.message.includes("fetch")) {
      showError(translations[currentLang].networkError)
    } else {
      showError(translations[currentLang].serverError)
    }
  }
}

// Language switching
function switchLanguage(lang) {
  currentLang = lang
  updateText()

  // Update active button
  langEnBtn.classList.toggle("active", lang === "en")
  langArBtn.classList.toggle("active", lang === "ar")

  // Save preference
  localStorage.setItem("preferred-language", lang)
}

// Initialize
function init() {
  // Load saved language preference
  const savedLang = localStorage.getItem("preferred-language")
  if (savedLang && translations[savedLang]) {
    currentLang = savedLang
  }

  // Set up event listeners
  langEnBtn.addEventListener("click", () => switchLanguage("en"))
  langArBtn.addEventListener("click", () => switchLanguage("ar"))
  retryButton.addEventListener("click", claimReward)

  // Update initial text and language buttons
  updateText()
  switchLanguage(currentLang)

  // Start the claim process
  claimReward()
}

// Start when DOM is loaded
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init)
} else {
  init()
}
