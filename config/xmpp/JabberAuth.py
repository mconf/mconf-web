#######################################################################
# DB Settings
# Just put your settings here.
########################################################################
db_name="mconf_production"
db_user="mconf"
db_pass="my-password"
db_host="my-server.com"
db_table="users"
db_username_field="login"
db_password_field="crypted_password"
db_salt_field="salt"
domain_suffix="@my-server.com"
auth_url="http://my-server.com/xmpp/me"

########################################################################
# Setup
########################################################################
import sys, logging, struct, hashlib, MySQLdb, requests

from struct import *
from xml.dom.minidom import parseString

sys.stderr = open('/var/log/ejabberd/extauth_err.log', 'a')

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s %(message)s',
                    filename='/var/log/ejabberd/extauth.log',
                    filemode='a')

try:
        database=MySQLdb.connect(host=db_host, port=3306, user=db_user, passwd=db_pass, db=db_name)
except:
        logging.debug("Unable to initialize database, check settings!")
dbcur=database.cursor()
logging.info('extauth script started, waiting for ejabberd requests')
class EjabberdInputError(Exception):
    def __init__(self, value):
        self.value = value
    def __str__(self):
        return repr(self.value)

########################################################################
# Declarations
########################################################################
def ejabberd_in():
                logging.debug("trying to read 2 bytes from ejabberd:")
                try:
                        input_length = sys.stdin.read(2)
                except IOError:
                        logging.debug("ioerror")
                if len(input_length) is not 2:
                        logging.debug("ejabberd sent us wrong things!")
                        raise EjabberdInputError('Wrong input from ejabberd!')
                logging.debug('got 2 bytes via stdin: %s'%input_length)
                (size,) = unpack('>h', input_length)
                logging.debug('size of data: %i'%size)
                income=sys.stdin.read(size).split(':')
                logging.debug("incoming data: %s"%income)
                return income

def ejabberd_out(bool):
                logging.debug("Ejabberd gets: %s" % bool)
                token = genanswer(bool)
                logging.debug("sent bytes: %#x %#x %#x %#x" % (ord(token[0]), ord(token[1]), ord(token[2]), ord(token[3])))
                sys.stdout.write(token)
                sys.stdout.flush()

def genanswer(bool):
                answer = 0
                if bool:
                        answer = 1
                token = pack('>hh', 2, answer)
                return token

def db_entry(in_user):
        ls=[None, None]
        dbcur.execute("SELECT %s,%s,%s FROM %s WHERE %s ='%s'"%(db_username_field,db_password_field,db_salt_field  , db_table, db_username_field, in_user))
        return dbcur.fetchone()

def isuser(in_user, in_host):
        data=db_entry(in_user)
        out=False
        if data==None:
                out=False
                logging.debug("Wrong username: %s"%(in_user))
        if in_user+"@"+in_host==data[0]+domain_suffix:
                out=True
        return out

def auth(in_user, in_host, password):
        data=db_entry(in_user)
        out=False
        if data==None:
                out=False
                logging.debug("Wrong username: %s"%(in_user))
        if in_user+"@"+in_host==data[0]+domain_suffix:
                if password==data[1] or hashlib.sha1("--"+data[2]+"--"+password+"--").hexdigest()==data[1]:
                        out=True
                else:
                        logging.debug("Wrong password for user: %s"%(in_user))
                        out=False
        else:
                out=False
        return out

def authByPass(in_user, in_password):
        out = False
        xml = requests.get(auth_url, auth=(in_user, in_password))
        dom = parseString(xml.text)
        username = dom.getElementsByTagName('username')[0].firstChild.data
        if in_user == username:
                out = True
        return out

def authByCookie(in_user, in_cookie):
        out = False
        cookies = dict(_mconf_session=pass_args[1])
        xml = requests.get(auth_url, cookies=cookies)
        dom = parseString(xml.text)
        username = dom.getElementsByTagName('username')[0].firstChild.data
        if in_user == username:
                out = True
        return out

def log_result(op, in_user, bool):
        if bool:
                logging.info("%s successful for %s"%(op, in_user))
        else:
                logging.info("%s unsuccessful for %s"%(op, in_user))

########################################################################
# Main Loop
########################################################################
while True:
        logging.debug("start of infinite loop")
        try:
                ejab_request = ejabberd_in()
        except EjabberdInputError, inst:
                logging.info("Exception occured: %s", inst)
                break
        logging.debug('operation: %s'%(ejab_request[0]))
        op_result = False
        if ejab_request[0] == "auth":
                pass_args = ejab_request[3].split('>>')
                if pass_args[0] == "AuthByPass":
                        op_result = auth(ejab_request[1], ejab_request[2], pass_args[1])
                        ejabberd_out(op_result)
                        log_result(ejab_request[0], ejab_request[1], op_result)
                elif pass_args[0] == "AuthByCookie":
                        op_result = authByCookie(ejab_request[1], pass_args[1])
                        ejabberd_out(op_result)
                        log_result(ejab_request[0], ejab_request[1], op_result)
                else:
                        op_result = auth(ejab_request[1], ejab_request[2], ejab_request[3])
                        ejabberd_out(op_result)
                        log_result(ejab_request[0], ejab_request[1], op_result)
        elif ejab_request[0] == "isuser":
                op_result = isuser(ejab_request[1], ejab_request[2])
                ejabberd_out(op_result)
                log_result(ejab_request[0], ejab_request[1], op_result)
        elif ejab_request[0] == "setpass":
                op_result=False
                ejabberd_out(op_result)
                log_result(ejab_request[0], ejab_request[1], op_result)

logging.debug("end of infinite loop")
logging.info('extauth script terminating')
database.close()
