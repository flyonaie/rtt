/***************************************************************************
  tag: Peter Soetens  Thu Oct 22 11:59:07 CEST 2009  PortInterface.cpp

                        PortInterface.cpp -  description
                           -------------------
    begin                : Thu October 22 2009
    copyright            : (C) 2009 Sylvain Joyeux
    email                : sylvain.joyeux@m4x.org

 ***************************************************************************
 *   This library is free software; you can redistribute it and/or         *
 *   modify it under the terms of the GNU General Public                   *
 *   License as published by the Free Software Foundation;                 *
 *   version 2 of the License.                                             *
 *                                                                         *
 *   As a special exception, you may use this file as part of a free       *
 *   software library without restriction.  Specifically, if other files   *
 *   instantiate templates or use macros or inline functions from this     *
 *   file, or you compile this file and link it with other files to        *
 *   produce an executable, this file does not by itself cause the         *
 *   resulting executable to be covered by the GNU General Public          *
 *   License.  This exception does not however invalidate any other        *
 *   reasons why the executable file might be covered by the GNU General   *
 *   Public License.                                                       *
 *                                                                         *
 *   This library is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   Lesser General Public License for more details.                       *
 *                                                                         *
 *   You should have received a copy of the GNU General Public             *
 *   License along with this library; if not, write to the Free Software   *
 *   Foundation, Inc., 59 Temple Place,                                    *
 *   Suite 330, Boston, MA  02111-1307  USA                                *
 *                                                                         *
 ***************************************************************************/


#include "PortInterface.hpp"
#include "../Service.hpp"
#include "../OperationCaller.hpp"
#include "../internal/ConnFactory.hpp"
#include "../internal/ConnectionIntrospector.hpp"
#include "../TaskContext.hpp"
#include <cstring>

using namespace RTT;
using namespace RTT::detail;
using namespace std;

PortInterface::PortInterface(const std::string& name)
    : name(name), fullName(name), iface(0), cmanager(this) {}

PortInterface::~PortInterface() {}

bool PortInterface::setName(const std::string& name) {
    if ( !connected() ) {
        this->name = name;
        updateFullName();
        return true;
    }
    return false;
}

void PortInterface::updateFullName() {
    fullName = getQualifiedName();
}

std::string PortInterface::getQualifiedName() const
{
    std::string qualified_name = getName();
    const RTT::DataFlowInterface *interface = getInterface();
    if (!interface) return qualified_name;

    const RTT::Service *service = interface->getService();
    while(service) {
        if (!service->getName().empty()) {
            qualified_name = service->getName() + "." + qualified_name;
        }
        service = service->getParent().get();
    }

    return qualified_name;
}

PortInterface& PortInterface::doc(const std::string& desc) {
    mdesc = desc;
    if (iface)
        iface->setPortDescription(name, desc);
    return *this;
}

bool PortInterface::connectedTo(PortInterface* port) {
    return cmanager.connectedTo(port);
}

bool PortInterface::isLocal() const
{ return serverProtocol() == 0; }
int PortInterface::serverProtocol() const
{ return 0; }

ConnID* PortInterface::getPortID() const
{ return new LocalConnID(this); }

Service* PortInterface::createPortObject()
{
#ifndef ORO_EMBEDDED
    Service* to = new Service( this->getName(), iface->getOwner() );
    to->addSynchronousOperation( "name",&PortInterface::getName, this).doc(
            "Returns the port name.");
    to->addSynchronousOperation("connected", &PortInterface::connected, this).doc("Check if this port is connected and ready for use.");

    typedef void (PortInterface::*disconnect_all)();
    to->addSynchronousOperation("disconnect", static_cast<disconnect_all>(&PortInterface::disconnect), this).doc("Disconnects this port from any connection it is part of.");

    to->addSynchronousOperation("showPortConnections",
        &PortInterface::showPortConnections, this).doc(
            "Logs a list of connections for this port.").arg(
                "depth", "Number of levels to look for: 1 will only list direct"
                " connections, more than 1 will also look at connected ports "
                "connections.");
    return to;
#else
    return 0;
#endif
}

bool PortInterface::removeConnection(ConnID* conn)
{
    return cmanager.removeConnection(conn);
}

void PortInterface::setInterface(DataFlowInterface* dfi) {
    iface = dfi;
    updateFullName();
}

DataFlowInterface* PortInterface::getInterface() const
{
    return iface;
}

internal::SharedConnectionBase::shared_ptr PortInterface::getSharedConnection() const
{
    return cmanager.getSharedConnection();
}

void PortInterface::showPortConnections(int depth) const
{
    if (depth < 1) depth = 1;

    ConnectionIntrospector ci(this);
    ci.createGraph(depth);
    std::cout << "\n" << ci << std::endl;
}
