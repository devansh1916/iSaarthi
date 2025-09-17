import React, { useState, useEffect } from 'react';
import { 
  Building, 
  Users, 
  AlertTriangle, 
  Clock, 
  CheckCircle, 
  ArrowRight,
  Search,
  Filter,
  MapPin,
  Calendar,
  User,
  Mail,
  Phone,
  ExternalLink
} from 'lucide-react';

const DepartmentAssignment = () => {
  const [departments, setDepartments] = useState([]);
  const [unassignedIssues, setUnassignedIssues] = useState([]);
  const [selectedDepartment, setSelectedDepartment] = useState(null);
  const [selectedIssues, setSelectedIssues] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  // Mock data - replace with actual API calls
  useEffect(() => {
    const mockDepartments = [
      {
        id: 1,
        name: "Public Works",
        description: "Infrastructure maintenance and road repairs",
        manager: "John Smith",
        email: "john.smith@city.gov",
        phone: "(555) 123-4567",
        capacity: 15,
        currentLoad: 8,
        specialties: ["Roads", "Bridges", "Sidewalks", "Drainage"],
        avgResolutionTime: "3-5 days",
        performance: 92
      },
      {
        id: 2,
        name: "Utilities",
        description: "Electrical, water, and gas infrastructure",
        manager: "Sarah Johnson",
        email: "sarah.johnson@city.gov",
        phone: "(555) 234-5678",
        capacity: 12,
        currentLoad: 5,
        specialties: ["Street Lights", "Water Lines", "Gas Lines", "Electrical"],
        avgResolutionTime: "2-4 days",
        performance: 88
      },
      {
        id: 3,
        name: "Sanitation",
        description: "Waste management and garbage collection",
        manager: "Mike Davis",
        email: "mike.davis@city.gov",
        phone: "(555) 345-6789",
        capacity: 20,
        currentLoad: 12,
        specialties: ["Garbage Collection", "Recycling", "Hazardous Waste"],
        avgResolutionTime: "1-2 days",
        performance: 95
      },
      {
        id: 4,
        name: "Parks & Recreation",
        description: "Public parks, playgrounds, and recreational facilities",
        manager: "Lisa Wilson",
        email: "lisa.wilson@city.gov",
        phone: "(555) 456-7890",
        capacity: 8,
        currentLoad: 3,
        specialties: ["Parks", "Playgrounds", "Sports Facilities", "Landscaping"],
        avgResolutionTime: "5-7 days",
        performance: 85
      },
      {
        id: 5,
        name: "Emergency Services",
        description: "Emergency response and urgent issues",
        manager: "Tom Brown",
        email: "tom.brown@city.gov",
        phone: "(555) 567-8901",
        capacity: 10,
        currentLoad: 2,
        specialties: ["Emergency Repairs", "Safety Hazards", "Urgent Issues"],
        avgResolutionTime: "1-3 days",
        performance: 98
      }
    ];

    const mockUnassignedIssues = [
      {
        id: 1,
        title: "Pothole on Main Street",
        description: "Large pothole causing traffic issues",
        location: "Main Street, Downtown",
        priority: "high",
        category: "Infrastructure",
        reportedBy: "John Doe",
        reportedAt: "2024-01-15T10:30:00Z",
        suggestedDepartment: "Public Works",
        confidence: 95
      },
      {
        id: 2,
        title: "Broken Street Light",
        description: "Street light not working at intersection",
        location: "Oak Avenue & 5th Street",
        priority: "medium",
        category: "Utilities",
        reportedBy: "Jane Smith",
        reportedAt: "2024-01-14T18:45:00Z",
        suggestedDepartment: "Utilities",
        confidence: 90
      },
      {
        id: 3,
        title: "Damaged Playground Equipment",
        description: "Broken swing set in city park",
        location: "Central Park Playground",
        priority: "medium",
        category: "Recreation",
        reportedBy: "Bob Johnson",
        reportedAt: "2024-01-13T08:15:00Z",
        suggestedDepartment: "Parks & Recreation",
        confidence: 85
      },
      {
        id: 4,
        title: "Sewer Backup",
        description: "Sewer backup causing flooding",
        location: "456 Pine Street",
        priority: "urgent",
        category: "Infrastructure",
        reportedBy: "Sarah Wilson",
        reportedAt: "2024-01-16T06:00:00Z",
        suggestedDepartment: "Emergency Services",
        confidence: 98
      }
    ];

    setDepartments(mockDepartments);
    setUnassignedIssues(mockUnassignedIssues);
  }, []);

  const filteredIssues = unassignedIssues.filter(issue => {
    const matchesSearch = issue.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         issue.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         issue.location.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filterStatus === 'all' || issue.priority === filterStatus;
    return matchesSearch && matchesFilter;
  });

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'urgent': return 'bg-red-100 text-red-800 border-red-200';
      case 'high': return 'bg-orange-100 text-orange-800 border-orange-200';
      case 'medium': return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'low': return 'bg-green-100 text-green-800 border-green-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };
  
  const getIssueBackgroundColor = (priority) => {
    switch (priority) {
      case 'high':
      case 'urgent':
        return 'bg-red-50';
      case 'medium':
        return 'bg-yellow-50';
      case 'low':
        return 'bg-green-50';
      default:
        return 'hover:bg-gray-50';
    }
  };

  const getConfidenceColor = (confidence) => {
    if (confidence >= 90) return 'text-green-600';
    if (confidence >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const handleSelectIssue = (issueId) => {
    setSelectedIssues(prev => 
      prev.includes(issueId) 
        ? prev.filter(id => id !== issueId)
        : [...prev, issueId]
    );
  };

  const handleAssignIssues = () => {
    if (selectedDepartment && selectedIssues.length > 0) {
      // Implement assignment logic
      console.log(`Assigning issues ${selectedIssues.join(', ')} to ${selectedDepartment.name}`);
      // Remove assigned issues from unassigned list
      setUnassignedIssues(prev => prev.filter(issue => !selectedIssues.includes(issue.id)));
      setSelectedIssues([]);
      setSelectedDepartment(null);
    }
  };

  const handleAutoAssign = () => {
    // Implement auto-assignment based on AI suggestions
    const autoAssignments = filteredIssues.map(issue => ({
      issueId: issue.id,
      departmentId: departments.find(d => d.name === issue.suggestedDepartment)?.id
    }));
    
    console.log('Auto-assigning issues:', autoAssignments);
    // Implement auto-assignment logic
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Department Assignment</h1>
        <div className="flex space-x-4">
          <button
            onClick={handleAutoAssign}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Auto-Assign All
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Unassigned Issues */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-md border border-gray-200">
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-semibold text-gray-900">Unassigned Issues</h2>
                <span className="bg-red-100 text-red-800 text-sm font-medium px-2 py-1 rounded-full">
                  {filteredIssues.length} issues
                </span>
              </div>
              
              {/* Search and Filter */}
              <div className="mt-4 flex gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                  <input
                    type="text"
                    placeholder="Search issues..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  />
                </div>
                <select
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="all">All Priorities</option>
                  <option value="urgent">Urgent</option>
                  <option value="high">High</option>
                  <option value="medium">Medium</option>
                  <option value="low">Low</option>
                </select>
              </div>
            </div>

            <div className="divide-y divide-gray-200 max-h-96 overflow-y-auto">
              {filteredIssues.map((issue) => (
                <div key={issue.id} className={`p-6 ${getIssueBackgroundColor(issue.priority)}`}>
                  <div className="flex items-start space-x-4">
                    <input
                      type="checkbox"
                      checked={selectedIssues.includes(issue.id)}
                      onChange={() => handleSelectIssue(issue.id)}
                      className="mt-1 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between mb-2">
                        <h3 className="text-sm font-medium text-gray-900 truncate">
                          {issue.title}
                        </h3>
                        <div className="flex items-center space-x-2">
                          <span className={`px-2 py-1 text-xs font-medium rounded-full border ${getPriorityColor(issue.priority)}`}>
                            {issue.priority.toUpperCase()}
                          </span>
                          <span className={`text-xs font-medium ${getConfidenceColor(issue.confidence)}`}>
                            {issue.confidence}% match
                          </span>
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mb-2">{issue.description}</p>
                      <div className="flex items-center space-x-4 text-xs text-gray-500">
                        <div className="flex items-center">
                          <MapPin className="w-3 h-3 mr-1" />
                          {issue.location}
                        </div>
                        <div className="flex items-center">
                          <Calendar className="w-3 h-3 mr-1" />
                          {new Date(issue.reportedAt).toLocaleDateString()}
                        </div>
                        <div className="flex items-center">
                          <User className="w-3 h-3 mr-1" />
                          {issue.reportedBy}
                        </div>
                      </div>
                      <div className="mt-2">
                        <span className="text-xs text-gray-500">Suggested: </span>
                        <span className="text-xs font-medium text-blue-600">{issue.suggestedDepartment}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Department Selection */}
        <div className="space-y-6">
          {/* Selected Issues Summary */}
          {selectedIssues.length > 0 && (
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="text-sm font-medium text-blue-800 mb-2">
                Selected Issues ({selectedIssues.length})
              </h3>
              <p className="text-xs text-blue-600">
                Choose a department to assign these issues to
              </p>
            </div>
          )}

          {/* Departments List */}
          <div className="bg-white rounded-lg shadow-md border border-gray-200">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">Departments</h2>
            </div>
            <div className="divide-y divide-gray-200">
              {departments.map((dept) => (
                <div
                  key={dept.id}
                  className={`p-4 cursor-pointer transition-colors ${
                    selectedDepartment?.id === dept.id 
                      ? 'bg-blue-50 border-l-4 border-blue-500' 
                      : 'hover:bg-gray-50'
                  }`}
                  onClick={() => setSelectedDepartment(dept)}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <Building className="w-4 h-4 text-gray-400" />
                        <h3 className="text-sm font-medium text-gray-900">{dept.name}</h3>
                      </div>
                      <p className="text-xs text-gray-600 mb-2">{dept.description}</p>
                      
                      {/* Department Stats */}
                      <div className="grid grid-cols-2 gap-2 text-xs">
                        <div>
                          <span className="text-gray-500">Load: </span>
                          <span className="font-medium">{dept.currentLoad}/{dept.capacity}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Performance: </span>
                          <span className="font-medium">{dept.performance}%</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Avg Time: </span>
                          <span className="font-medium">{dept.avgResolutionTime}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Manager: </span>
                          <span className="font-medium">{dept.manager}</span>
                        </div>
                      </div>

                      {/* Specialties */}
                      <div className="mt-2">
                        <div className="flex flex-wrap gap-1">
                          {dept.specialties.map((specialty) => (
                            <span
                              key={specialty}
                              className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded"
                            >
                              {specialty}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Contact Info */}
                      <div className="mt-2 flex items-center space-x-4 text-xs text-gray-500">
                        <div className="flex items-center">
                          <Mail className="w-3 h-3 mr-1" />
                          {dept.email}
                        </div>
                        <div className="flex items-center">
                          <Phone className="w-3 h-3 mr-1" />
                          {dept.phone}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Assignment Actions */}
          {selectedIssues.length > 0 && selectedDepartment && (
            <div className="bg-white rounded-lg shadow-md border border-gray-200 p-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Assignment Details</h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Assigning {selectedIssues.length} issue(s) to:
                  </label>
                  <div className="flex items-center space-x-2">
                    <Building className="w-4 h-4 text-gray-400" />
                    <span className="font-medium">{selectedDepartment.name}</span>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Department Load:
                  </label>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-blue-600 h-2 rounded-full"
                      style={{ width: `${(selectedDepartment.currentLoad / selectedDepartment.capacity) * 100}%` }}
                    ></div>
                  </div>
                  <p className="text-xs text-gray-500 mt-1">
                    {selectedDepartment.currentLoad}/{selectedDepartment.capacity} issues
                  </p>
                </div>

                <div className="flex space-x-3">
                  <button
                    onClick={handleAssignIssues}
                    className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center space-x-2"
                  >
                    <ArrowRight className="w-4 h-4" />
                    <span>Assign Issues</span>
                  </button>
                  <button
                    onClick={() => {
                      setSelectedIssues([]);
                      setSelectedDepartment(null);
                    }}
                    className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default DepartmentAssignment;
