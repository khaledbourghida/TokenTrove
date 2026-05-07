import smtplib
import pandas as pd
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SENDER_EMAIL = "prokhaled64@gmail.com"
SENDER_PASSWORD = "ictmcdnywyzjszdq"
DOWNLOAD_LINK = "https://comforting-torte-626735.netlify.app/"

df = pd.read_csv("emails.csv")
emails = df["email"].dropna().tolist()

subject = "🎉 NEW version : fix the log in error -- 🎉 الإصدار الجديد: إصلاح خطأ تسجيل الدخول!"
body = f"""
Hello heros ,
i want to tell you that the error of log in (email verification code dont send) has fixed and now you can just install the new version from our website and enjoy , and dont forget : work more -> get more / be fast -> become champion

-----------------------
مرحبا الأبطال,
أريد أن أخبرك أن خطأ تسجيل الدخول (عدم إرسال رمز التحقق من البريد الإلكتروني) قد تم إصلاحه ويمكنك الآن تثبيت الإصدار الجديد من موقعنا والاستمتاع به، ولا تنس: اعمل أكثر -> احصل على المزيد / كن سريعًا -> تكن بطلًا

--------------------------------

the download link : {DOWNLOAD_LINK}
رابط التحميل : {DOWNLOAD_LINK}
"""

try:
    # Create SMTP session
    server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    server.ehlo()
    server.starttls()  # Secure the connection
    server.login(SENDER_EMAIL, SENDER_PASSWORD)

    for recipient in emails:
        msg = MIMEMultipart()
        msg["From"] = SENDER_EMAIL
        msg["To"] = recipient
        msg["Subject"] = subject
        msg.attach(MIMEText(body, "plain"))

        server.sendmail(SENDER_EMAIL, recipient, msg.as_string())
        print(f"✅ Email sent to {recipient}")

    server.quit()
except Exception as e:
    print(f"❌ Error: {e}")
