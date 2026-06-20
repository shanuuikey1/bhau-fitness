using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace BhauFitnessApi.Services;

public class SmtpSettings
{
    public string Host { get; set; } = string.Empty;
    public int Port { get; set; } = 587;
    public string User { get; set; } = string.Empty;
    public string Pass { get; set; } = string.Empty;
    public string FromEmail { get; set; } = string.Empty;
    public string FromName { get; set; } = "BHAU FITNESS";
}

public interface IEmailSender
{
    Task SendAsync(string toEmail, string subject, string body);
}

/// SMTP email sender. Reads credentials from the "Smtp" config section
/// (set them via `dotnet user-secrets`, never commit them). If no host is
/// configured it falls back to logging the message — so password reset still
/// "works" for local testing before real SMTP is wired up.
public class EmailSender : IEmailSender
{
    private readonly SmtpSettings _settings;
    private readonly ILogger<EmailSender> _logger;

    public EmailSender(IConfiguration config, ILogger<EmailSender> logger)
    {
        _settings = config.GetSection("Smtp").Get<SmtpSettings>() ?? new SmtpSettings();
        _logger = logger;
    }

    public async Task SendAsync(string toEmail, string subject, string body)
    {
        if (string.IsNullOrWhiteSpace(_settings.Host))
        {
            // No SMTP configured yet — log so local testing can grab the link.
            _logger.LogWarning(
                "SMTP not configured. Would send to {To} | Subject: {Subject}\n{Body}",
                toEmail, subject, body);
            return;
        }

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(_settings.FromName, _settings.FromEmail));
        message.To.Add(MailboxAddress.Parse(toEmail));
        message.Subject = subject;
        message.Body = new BodyBuilder { HtmlBody = body }.ToMessageBody();

        using var client = new SmtpClient();
        // Port 587 uses STARTTLS — MailKit handles Gmail's TLS handshake reliably,
        // unlike System.Net.Mail's SmtpClient.
        await client.ConnectAsync(_settings.Host, _settings.Port, SecureSocketOptions.StartTls);
        await client.AuthenticateAsync(_settings.User, _settings.Pass);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
