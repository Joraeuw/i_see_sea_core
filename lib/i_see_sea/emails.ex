defmodule ISeeSea.Emails do
  @moduledoc """
  Manages emails
  """
  alias ISeeSea.Mailer
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Helpers.Environment
  import Swoosh.Email

  def account_confirmation_email(%User{email: email, username: username}, confirmation_token) do
    confirmation_link = confirmation_url(confirmation_token)

    new()
    |> to(email)
    |> from(Environment.i_see_sea_mail())
    |> subject("Email Confirmation")
    |> html_body("""
    <html>
    <body>
      <p>Здравейте #{username},</p>
      <p>Добре дошли в общността на ICC! Много се радваме, че сте с нас.</p>
      <p>Моля, потвърдете своя имейл, като кликнете на този линк: <a href="#{confirmation_link}">Потвърдете имейла</a></p>
      <p>Като член на ICC ще имате достъп до редица функции и ресурси, които ще подобрят вашето изживяване. Нашата цел е да ви предоставим най-доброто обслужване.</p>
      <ul>
        <li>Плавно и лесно за използване изживяване</li>
        <li>Редовни актуализации</li>
        <li>Изключително обслужване на клиенти</li>
      </ul>
      <p>Вашето изживяване ще бъде приятно и гладко. 🙂<br>Без излишни нерви, без проблеми.</p>
      <p>Ако имате въпроси или се нуждаете от помощ, не се колебайте да се свържете с нашия екип за поддръжка на <a href="mailto:iliad.support@tu-varna.bg">iliad.support@tu-varna.bg</a></p>
      <p>Благодарим ви и още веднъж, добре дошли в ICC!</p>
      <p>С най-добри пожелания,<br>Екипът на ICC</p>

      <hr>

      <p>Hi #{username},</p>
      <p>Welcome to the ICC community! We are thrilled to have you on board.</p>
      <p>Please confirm your email by clicking on this link: <a href="#{confirmation_link}">Confirm Email</a></p>
      <p>As a member of ICC, you will have access to a range of features and resources that will enhance your experience. We aim to provide you with the best service possible.</p>
      <ul>
        <li>A smooth and user-friendly experience</li>
        <li>Regular updates</li>
        <li>Exceptional customer support</li>
      </ul>
      <p>Your experience is going to be nice and smooth. 🙂<br>No frustrations, no trouble.</p>
      <p>If you have any questions or need assistance, feel free to reach out to our support team at <a href="mailto:iliad.support@tu-varna.bg">iliad.support@tu-varna.bg</a></p>
      <p>Thank you, and once again, welcome to ICC!</p>
      <p>Best regards,<br>The ICC Team</p>
    </body>
    </html>
    """)
    |> text_body("""
    Здравейте #{username},

    Добре дошли в общността на ICC! Много се радваме, че сте с нас.

    Моля, потвърдете своя имейл, като кликнете на този линк: #{confirmation_link}

    Като член на ICC ще имате достъп до редица функции и ресурси, които ще подобрят вашето изживяване. Нашата цел е да ви предоставим най-доброто обслужване.
    Ето какво можете да очаквате:
    - Плавно и лесно за използване изживяване
    - Редовни актуализации
    - Изключително обслужване на клиенти

    Вашето изживяване ще бъде приятно и гладко. 🙂
    Без излишни нерви, без проблеми.

    Ако имате въпроси или се нуждаете от помощ, не се колебайте да се свържете с нашия екип за поддръжка на iliad.support@tu-varna.bg
    Благодарим ви и още веднъж, добре дошли в ICC!

    С най-добри пожелания,
    Екипът на ICC

    ------------------------------------------------------------

    Hi #{username},

    Welcome to the ICC community! We are thrilled to have you on board.

    Please confirm your email by clicking on this link: #{confirmation_link}

    As a member of ICC, you will have access to a range of features and resources that will enhance your experience. We aim to provide you with the best service possible.
    Here's what you can expect:
    - A smooth and user-friendly experience
    - Regular updates
    - Exceptional customer support

    Your experience is going to be nice and smooth. 🙂
    No frustrations, no trouble.

    If you have any questions or need assistance, feel free to reach out to our support team at iliad.support@tu-varna.bg
    Thank you, and once again, welcome to ICC!

    Best regards,
    The ICC Team
    """)
    |> Mailer.deliver()
  end

  defp confirmation_url(token) do
    "#{Environment.backend_url()}/api/verify-email/#{token}"
  end
end
