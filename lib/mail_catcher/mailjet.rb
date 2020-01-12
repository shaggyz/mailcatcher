module MailCatcher
  module Mailjet

    class Mail
      def initialize(from, to, subject, text_part = '', html_part = '', attachments = [])
        @uid = SecureRandom.uuid.gsub(/[-]/,'')
        @from = from
        @to = to
        @subject = subject
        @text_part = text_part
        @html_part = html_part
        @attachments = attachments
      end

      def get_sender
        "#{@from['Name']} <#{@from['Email']}>"
      end

      def get_recipients
        to = []
        @to.each do |receiver|
          to << "#{receiver['Name']} <#{receiver['Email']}>"
        end

        to
      end

      def to_smtp_payload
        from = get_sender
        to = get_recipients

        head = "#{DateTime.now.strftime('Date: %a, %d %b %Y %H:%M:%S %z')}
Subject: #{@subject}
From: #{from}
To: #{to.join(', ')}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{@uid}

"
        body_id = SecureRandom.uuid.gsub(/[-]/,'')
        body = ''
        alternate = false
        unless @text_part.empty? or @html_part.empty?
          alternate = true
          body = "--#{@uid}
Content-Type: multipart/alternative; boundary=#{body_id}

"
        end

        unless @text_part.empty?
          uid = alternate ? body_id : @uid
          body.concat("--#{uid}
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

#{@text_part}

")
        end

        unless @html_part.empty?
          uid = alternate ? body_id : @uid
          body.concat("--#{uid}
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

#{@html_part}

")
        end

        body.concat("--#{alternate ? body_id : @uid}--
")
        attachments = ''
        unless @attachments.empty?
          @attachments.each do |attachment|
            attachments.concat(
                "--#{@uid}
Content-Type: #{attachment['ContentType']}
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=#{attachment['Filename']}

#{attachment['Base64Content']}

--#{@uid}--
"
            )
          end
        end

        footer = ''
        if alternate and @attachments.empty?
          footer = "--#{@uid}--
"
        end

        "#{head}#{body}#{attachments}#{footer}"
        end
    end
  end
end