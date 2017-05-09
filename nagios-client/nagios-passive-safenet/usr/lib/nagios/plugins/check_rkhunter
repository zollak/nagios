#! /bin/sh
#
# check_rkhunter
#
# Created by zollak on 2015.03.27.
# Last modify: 2015.03.28.
# This check is designed to run not very often, I preffered daily running. Than just being a cron job.
#
# Needs the following sudo rule:
# nagios ALL=NOPASSWD:/usr/bin/rkhunter
#
# You need to install rkhunter with source package, not dpkg!


# Set this to the email address where reports and run output should be sent
# (default: root)
# You can use more e-mail addresses in /etc/aliases (If you edit this, don't forget running the newaliases command)
REPORT_EMAIL="root"

# Nicenesses range from -20 (most favorable scheduling) to 19 (least favorable)
# (default: 0)
NICE="0"

PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1.0 $' | sed -e 's/[^0-9.]//g'`
RKHUNTER=/usr/bin/rkhunter
SENDMAIL=/usr/sbin/sendmail

# source nagios help
. $PROGPATH/utils.sh

if [ -z "$NICE" ]; then
    NICE=0
fi

#Don't run if there is an an rkhunter running
if pgrep -f $RKHUNTER >/dev/null ; then
       echo "WARNING: rkhunter still running!, check it out"
       exit 1
fi

print_usage() {
        echo "Usage: $PROGNAME"
}

print_help() {
        print_revision $PROGNAME $REVISION
        echo ""
        print_usage
        echo ""
        echo "This plugin checks security status using the root kit hunter package."
        echo ""
        support
        exit 0
}

case "$1" in
        --help)
                print_help
                exit 0
                ;;
        -h)
                print_help
                exit 0
                ;;
        --version)
                print_revision $PROGNAME $REVISION
                exit 0
                ;;
        -V)
                print_revision $PROGNAME $REVISION
                exit 0
                ;;
        *)
                OUTFILE=`mktemp`
                $RKHUNTER --cronjob --report-warnings-only --appendlog > $OUTFILE
                status=$?

                # send mail if rkhunter has warning report
                if [ -s "$OUTFILE" -a -n "$REPORT_EMAIL" ]; then
                (
                  echo "Subject: [rkhunter] $(hostname -f) - Daily report"
                  echo "To: $REPORT_EMAIL"
                  echo ""
                  cat $OUTFILE
                ) | $SENDMAIL $REPORT_EMAIL
                fi

                # Now test the status
                if test ${status} -eq 127; then
                        echo "rkhunter UNKNOWN - command not found (did you install it?)"
                        exit -1
                elif test ${status} -ne 0 ; then
                        echo "WARNING - rkhunter produced a warning, see /var/log/rkhunter.log"
                        grep Warning /var/log/rkhunter.log  | tail -n 1
                        exit 1
                fi
                if cat $OUTFILE | egrep infected > /dev/null; then
                        echo CRITICAL - rkhunter infection detected!
                        rm -f $OUTFILE
                        exit 2
                else
                        echo OK: Everything good from rkhunter
                        exit 0
                fi
                ;;
esac

