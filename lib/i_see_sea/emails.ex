defmodule ISeeSea.Emails do
  @moduledoc """
  Manages emails
  """
  alias ISeeSea.Mailer
  alias ISeeSea.DB.Models.User
  alias ISeeSea.Helpers.Environment
  require Logger
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
    |> case do
      {:ok, _response} = response ->
        Logger.info("Account confirmatrion link sent successfully to #{email}")
        response

      {:error, reason} = error ->
        Logger.error(
          "Failed to send account confirmatrion link to #{email}. Reason: #{inspect(reason)}"
        )

        error
    end
  end

  def password_reset_email(user, token) do
    reset_url = password_reset_url(token)

    email =
      new()
      |> to(user.email)
      |> from({"I See Sea Team", Environment.i_see_sea_mail()})
      |> subject("Инструкции за нулиране на парола / Reset Password Instructions")
      |> html_body("""
      <p>Здравейте #{user.username},</p>
      <p>Можете да нулирате паролата си, като кликнете <a href="#{reset_url}">тук</a>.</p>
      <p>Ако не сте заявили това, моля игнорирайте този имейл.</p>

      <hr>

      <p>Hello #{user.username},</p>
      <p>You can reset your password by clicking <a href="#{reset_url}">here</a>.</p>
      <p>If you did not request this, please ignore this email.</p>
      """)
      |> text_body("""
      Здравейте #{user.username},

      Можете да нулирате паролата си, като кликнете на следния линк:
      #{reset_url}

      Ако не сте заявили това, моля игнорирайте този имейл.

      ----------------------------------------

      Hello #{user.username},

      You can reset your password by clicking the link below:
      #{reset_url}

      If you did not request this, please ignore this email.
      """)

    case Mailer.deliver(email) do
      {:ok, _response} = response ->
        Logger.info("Password reset email sent successfully to #{user.email}")
        response

      {:error, reason} = error ->
        Logger.error(
          "Failed to send password reset email to #{user.email}. Reason: #{inspect(reason)}"
        )

        error
    end
  end

  def contact_us_email(
        %{
          "email" => email,
          "message" => message,
          "name" => name
        } = params
      ) do
    new()
    |> to(["joraeuw@gmail.com", "iliad.support@tu-varna.bg"])
    |> from({"Contact Form", Environment.i_see_sea_mail()})
    |> subject("New Contact Form Submission")
    |> html_body("""
      <h1>Contact Form Submission</h1>
      <p><strong>Name:</strong> #{name}</p>
      <p><strong>Email:</strong> #{email}</p>
      <p><strong>Phone:</strong> #{Map.get(params, "phone", "not provided")}</p>
      <p><strong>Organization:</strong> #{Map.get(params, "organization", "not provided")}</p>
      <p><strong>Message:</strong> #{message}</p>
    """)
    |> text_body("""
      Contact Form Submission

      Name: #{name}
      Email: #{email}
      Phone: #{Map.get(params, "phone", "not provided")}
      Organization: #{Map.get(params, "organization", "not provided")}
      Message: #{message}
    """)
    |> Mailer.deliver()

    new()
    |> to(email)
    |> from(Environment.i_see_sea_mail())
    |> subject("Потвърждение за получен сигнал / Issue Acknowledgment")
    |> html_body("""
      <p>Здравейте #{name},</p>
      <p>Благодарим ви, че се свързахте с нас! Искаме да ви уверим, че вашият въпрос е получен и нашият екип вече работи по него. Ще се постараем да се свържем с вас възможно най-скоро със съответното решение.</p>
      <p>Благодарим ви за търпението и разбирането.</p>

      <hr>

      <p>Hello #{name},</p>
      <p>Thank you for reaching out to us! We want to let you know that we've received your inquiry, and our team is actively working on it. We will do our best to get back to you as soon as possible with a resolution.</p>
      <p>We appreciate your patience and understanding.</p>
    """)
    |> text_body("""
      Здравейте #{name},

      Благодарим ви, че се свързахте с нас! Искаме да ви уверим, че вашият въпрос е получен и нашият екип вече работи по него. Ще се постараем да се свържем с вас възможно най-скоро със съответното решение.

      Благодарим ви за търпението и разбирането.

      ----------------------------------------

      Hello #{name},

      Thank you for reaching out to us! We want to let you know that we've received your inquiry, and our team is actively working on it. We will do our best to get back to you as soon as possible with a resolution.

      We appreciate your patience and understanding.
    """)
    |> Mailer.deliver()
  end

  defp confirmation_url(token) do
    "#{Environment.backend_url()}/verify-email/#{token}"
  end

  defp password_reset_url(token) do
    "#{Environment.backend_url()}/change_password/#{token}"
  end
end
