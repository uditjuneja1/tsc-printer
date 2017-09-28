require "../codemap"

module Tsc
  module Command
    # This module implements **Status Polling and Immediate Commands**.
    module Status
      # Immediate commands

      CANCEL            = "\e!."
      DISABLE_IMMEDIATE = "\e!D"
      FEED              = "\e!F"
      PAUSE             = "\e!P"
      RESET             = "\e!R"
      RESTART           = "\e!C"
      RESTART_ONLY_AUTO = "\e!Q"
      STATUS            = "\e!?"
      STATUS_DETAILED   = "\e!S"
      UNPAUSE           = "\e!O"

      # Non-immediate commands

      CODE_PAGE_COUNTRY_CODE = "\e~!I"
      DUMP                   = "\e~!D"
      ENABLE_IMMEDIATE       = "\e~!E"
      FILES                  = "\e~!F"
      LINE_MODE_DISABLE      = "\eZ"
      LINE_MODE_ENABLE       = "\eY"
      MEMORY                 = "\e~!A"
      MILEAGE                = "\e~!@"
      MODEL                  = "\e~!T"
      RTC                    = "\e~!C"

      # Cancels all printing files.
      #
      # This is an immediate command.
      #
      # **Since:**
      # - This command has been supported since V7.00 EZ and later firmware.
      #
      # ```
      # printer.cancel
      # ```
      def cancel
        @socket << CANCEL
      end

      # Disables all immediate commands.
      #
      # This is an immediate command.
      #
      # **Since:**
      # - This command has been supported since V6.61 EZ and later firmware.
      #
      # ```
      # printer.disable_immediate
      # ```
      def disable_immediate
        @socket << DISABLE_IMMEDIATE
      end

      # Feeds a label. This function is the same as pressing the FEED button.
      #
      # This is an immediate command.
      #
      # **Since:**
      # - This command has been supported since V7.00 EZ and later firmware.
      #
      # ```
      # printer.feed
      # ```
      def feed
        @socket << FEED
      end

      # Pauses the printer.
      #
      # This is an immediate command.
      #
      # **Since:**
      # - This command has been supported since V6.93 EZ and later firmware.
      #
      # ```
      # printer.pause
      # ```
      def pause
        @socket << PAUSE
      end

      # Resets the printer. Files downloaded in memory will be deleted. This command cannot be sent in dump mode.
      #
      # This is an immediate command.
      #
      # ```
      # printer.reset
      # ```
      def reset
        @socket << RESET
      end

      # Restarts the printer and does not run AUTO.BAS.
      #
      # This is an immediate command.
      #
      # **Note:**
      # - When the printer receives this command, the printer will restart itself whether AUTO.BAS exists or not.
      #
      # **Since:**
      # - This command has been supported since V5.23 EZ and later firmware.
      #
      # ```
      # printer.restart
      # ```
      def restart
        @socket << RESTART
      end

      # Restarts the printer only if AUTO.BAS exists.
      #
      # This is an immediate command.
      #
      # **Note:**
      # - If there is no AUTO.BAS file loaded on the printer, the printer will not restart itself.
      #
      # **Since:**
      # - This command has been supported since V6.72 EZ and later firmware.
      #
      # ```
      # printer.restart_only_auto
      # ```
      def restart_only_auto
        @socket << RESTART_AUTO_BAS
      end

      # Obtains the printer status at any time, even in the event of printer
      # error.
      #
      # This is an immediate command.
      #
      # ```
      # printer.status # => :normal
      # printer.status # => :ribbon_empty_head_open
      # ```
      def status : Symbol
        @socket << STATUS
        resp = @socket.read_byte
        Codemap::DETAILS[resp]
      end

      # Obtains detailed status information of the printer, even in the event of
      # printer error.
      #
      # **Since:**
      # - This command has been supported since V6.29 EZ and later firmware.
      #
      # ```
      # printer.status_detailed # => { message: :waiting_to_press_print_key, warning: :receive_buffer_full, printer_error: :print_head_error, media_error: :paper_empty }
      # ```
      def status_detailed
        slice = Bytes.new(8)
        @socket << STATUS_DETAILED
        @socket.read(slice)

        Codemap.convert_detailed_status_response(slice)
      end

      # Retrieves the mileage of the printer.
      #
      # This is an immediate command.
      #
      # ```
      # printer.mileage # => 89
      # ```
      def mileage : Int32
        @socket << MILEAGE
        resp = @socket.gets('\r', true)
        resp.not_nil!.to_i
      end

      # Cancels the pause status of printer.
      #
      # This is an immediate command.
      #
      # **Since:**
      # - This command has been supported since V6.93 EZ and later firmware.
      #
      # ```
      # printer.unpause
      # ```
      def unpause
        @socket << UNPAUSE
      end

      # Determines whether a Real Time Clock is installed in the printer.
      #
      # ```
      # printer.has_rtc? # => true
      # ```
      def has_rtc? : Bool
        @socket << RTC
        resp = @socket.read_byte

        return true if resp == '1'.ord
        false
      end

      # Retrieves the model name and number of the printer.
      #
      # ```
      # printer.model # => "TTP245C"
      # ```
      def model : String
        slice = Bytes.new(16)
        @socket << MODEL
        len = @socket.read(slice)

        String.new(slice[0, len])
      end
    end
  end
end
