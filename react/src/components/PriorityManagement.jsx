import React, { useState, useEffect } from 'react';
import { 
  AlertTriangle, 
  Clock, 
  CheckCircle, 
  XCircle, 
  TrendingUp,
  TrendingDown,
  Star,
  Zap,
  Shield,
  Users,
  MapPin,
  Calendar,
  Filter,
  Search,
  Settings,
  BarChart3,
  Target
} from 'lucide-react';

const PriorityManagement = () => {
  const [issues, setIssues] = useState([]);
  const [priorityRules, setPriorityRules] = useState([]);
  const [smartPriorities, setSmartPriorities] = useState([]);
  const [selectedIssues, setSelectedIssues] = useState([]);
  const [showRules, setShowRules] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterPriority, setFilterPriority] = useState('all');

  // Mock data - replace with actual API calls
  useEffect(() => {
    const mockIssues = [
      {
        id: 1,
        title: "Pothole on Main Street",
        description: "Large pothole causing traffic issues and vehicle damage",
        location: "Main Street, Downtown",
        currentPriority: "medium",
        smartPriority: "high",
        confidence: 92,
        category: "Infrastructure",
        reportedBy: "John Doe",
        reportedAt: "2024-01-15T10:30:00Z",
        department: "Public Works",
        impactScore: 85,
        urgencyScore: 90,
        complexityScore: 60,
        factors: ["High traffic area", "Safety hazard", "Vehicle damage reports"]
      },
      {
        id: 2,
        title: "Broken Street Light",
        description: "Street light not working at intersection",
        location: "Oak Avenue & 5th Street",
        currentPriority: "low",
        smartPriority: "medium",
        confidence: 78,
        category: "Utilities",
        reportedBy: "Jane Smith",
        reportedAt: "2024-01-14T18:45:00Z",
        department: "Utilities",
        impactScore: 70,
        urgencyScore: 65,
        complexityScore: 40,
        factors: ["Night safety concern", "Intersection visibility"]
      },
      {
        id: 3,
        title: "Sewer Backup",
        description: "Sewer backup causing flooding in residential area",
        location: "456 Pine Street",
        currentPriority: "urgent",
        smartPriority: "urgent",
        confidence: 98,
        category: "Infrastructure",
        reportedBy: "Sarah Wilson",
        reportedAt: "2024-01-16T06:00:00Z",
        department: "Emergency Services",
        impactScore: 95,
        urgencyScore: 98,
        complexityScore: 80,
        factors: ["Health hazard", "Property damage", "Emergency situation"]
      },
      {
        id: 4,
        title: "Damaged Playground Equipment",
        description: "Broken swing set in city park",
        location: "Central Park Playground",
        currentPriority: "low",
        smartPriority: "medium",
        confidence: 75,
        category: "Recreation",
        reportedBy: "Bob Johnson",
        reportedAt: "2024-01-13T08:15:00Z",
        department: "Parks & Recreation",
        impactScore: 60,
        urgencyScore: 55,
        complexityScore: 30,
        factors: ["Child safety", "Recreation impact"]
      },
      {
        id: 5,
        title: "Garbage Collection Missed",
        description: "Garbage not collected on scheduled day",
        location: "123 Elm Street",
        currentPriority: "low",
        smartPriority: "low",
        confidence: 88,
        category: "Sanitation",
        reportedBy: "Mike Brown",
        reportedAt: "2024-01-12T14:20:00Z",
        department: "Sanitation",
        impactScore: 45,
        urgencyScore: 40,
        complexityScore: 20,
        factors: ["Service disruption", "Odor concerns"]
      }
    ];

    const mockPriorityRules = [
      {
        id: 1,
        name: "Safety Hazard Rule",
        description: "Issues involving safety hazards are automatically high priority",
        conditions: ["category:Infrastructure", "keywords:safety,hazard,danger"],
        priority: "high",
        weight: 0.9,
        active: true
      },
      {
        id: 2,
        name: "Emergency Services Rule",
        description: "Issues assigned to Emergency Services are urgent",
        conditions: ["department:Emergency Services"],
        priority: "urgent",
        weight: 1.0,
        active: true
      },
      {
        id: 3,
        name: "High Traffic Area Rule",
        description: "Issues in high traffic areas get higher priority",
        conditions: ["location:Main Street", "location:Downtown", "location:Highway"],
        priority: "high",
        weight: 0.8,
        active: true
      },
      {
        id: 4,
        name: "Recent Reports Rule",
        description: "Recently reported issues get higher priority",
        conditions: ["reportedAt:last24hours"],
        priority: "medium",
        weight: 0.6,
        active: true
      },
      {
        id: 5,
        name: "Multiple Reports Rule",
        description: "Issues with multiple reports get higher priority",
        conditions: ["reportCount:>3"],
        priority: "high",
        weight: 0.7,
        active: false
      }
    ];

    setIssues(mockIssues);
    setPriorityRules(mockPriorityRules);
  }, []);

  const filteredIssues = issues.filter(issue => {
    const matchesSearch = issue.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         issue.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         issue.location.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesFilter = filterPriority === 'all' || issue.smartPriority === filterPriority;
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

  const getScoreColor = (score) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  const handleSelectIssue = (issueId) => {
    setSelectedIssues(prev => 
      prev.includes(issueId) 
        ? prev.filter(id => id !== issueId)
        : [...prev, issueId]
    );
  };

  const handleBulkPriorityUpdate = (newPriority) => {
    // Implement bulk priority update
    console.log(`Updating priority to ${newPriority} for issues:`, selectedIssues);
    setSelectedIssues([]);
  };

  const handleApplySmartPriorities = () => {
    // Implement smart priority application
    console.log('Applying smart priorities to all issues');
  };

  const priorityStats = {
    urgent: issues.filter(i => i.smartPriority === 'urgent').length,
    high: issues.filter(i => i.smartPriority === 'high').length,
    medium: issues.filter(i => i.smartPriority === 'medium').length,
    low: issues.filter(i => i.smartPriority === 'low').length
  };

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Smart Priority Management</h1>
        <div className="flex space-x-4">
          <button
            onClick={() => setShowRules(!showRules)}
            className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            <Settings className="w-4 h-4" />
            <span>Priority Rules</span>
          </button>
          <button
            onClick={handleApplySmartPriorities}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Apply Smart Priorities
          </button>
        </div>
      </div>

      {/* Priority Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Urgent</p>
              <p className="text-2xl font-bold text-red-600">{priorityStats.urgent}</p>
            </div>
            <AlertTriangle className="w-8 h-8 text-red-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">High</p>
              <p className="text-2xl font-bold text-orange-600">{priorityStats.high}</p>
            </div>
            <TrendingUp className="w-8 h-8 text-orange-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Medium</p>
              <p className="text-2xl font-bold text-yellow-600">{priorityStats.medium}</p>
            </div>
            <Clock className="w-8 h-8 text-yellow-500" />
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Low</p>
              <p className="text-2xl font-bold text-green-600">{priorityStats.low}</p>
            </div>
            <CheckCircle className="w-8 h-8 text-green-500" />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Issues List */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-md border border-gray-200">
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-semibold text-gray-900">Priority Analysis</h2>
                <div className="flex space-x-2">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                    <input
                      type="text"
                      placeholder="Search issues..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                  <select
                    value={filterPriority}
                    onChange={(e) => setFilterPriority(e.target.value)}
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
            </div>

            <div className="divide-y divide-gray-200 max-h-96 overflow-y-auto">
              {filteredIssues.map((issue) => (
                <div key={issue.id} className={`p-6 ${getIssueBackgroundColor(issue.smartPriority)}`}>
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
                          <span className={`px-2 py-1 text-xs font-medium rounded-full border ${getPriorityColor(issue.currentPriority)}`}>
                            Current: {issue.currentPriority.toUpperCase()}
                          </span>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full border ${getPriorityColor(issue.smartPriority)}`}>
                            Smart: {issue.smartPriority.toUpperCase()}
                          </span>
                          <span className={`text-xs font-medium ${getConfidenceColor(issue.confidence)}`}>
                            {issue.confidence}%
                          </span>
                        </div>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">{issue.description}</p>
                      
                      {/* Priority Factors */}
                      <div className="mb-3">
                        <p className="text-xs font-medium text-gray-700 mb-1">Priority Factors:</p>
                        <div className="flex flex-wrap gap-1">
                          {issue.factors.map((factor, index) => (
                            <span
                              key={index}
                              className="px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded"
                            >
                              {factor}
                            </span>
                          ))}
                        </div>
                      </div>

                      {/* Scores */}
                      <div className="grid grid-cols-3 gap-4 text-xs">
                        <div>
                          <span className="text-gray-500">Impact: </span>
                          <span className={`font-medium ${getScoreColor(issue.impactScore)}`}>
                            {issue.impactScore}/100
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-500">Urgency: </span>
                          <span className={`font-medium ${getScoreColor(issue.urgencyScore)}`}>
                            {issue.urgencyScore}/100
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-500">Complexity: </span>
                          <span className={`font-medium ${getScoreColor(issue.complexityScore)}`}>
                            {issue.complexityScore}/100
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center space-x-4 text-xs text-gray-500 mt-2">
                        <div className="flex items-center">
                          <MapPin className="w-3 h-3 mr-1" />
                          {issue.location}
                        </div>
                        <div className="flex items-center">
                          <Calendar className="w-3 h-3 mr-1" />
                          {new Date(issue.reportedAt).toLocaleDateString()}
                        </div>
                        <div className="flex items-center">
                          <Users className="w-3 h-3 mr-1" />
                          {issue.department}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Bulk Actions */}
          {selectedIssues.length > 0 && (
            <div className="mt-4 bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-blue-800">
                  {selectedIssues.length} issue(s) selected
                </span>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleBulkPriorityUpdate('urgent')}
                    className="px-3 py-1 bg-red-600 text-white text-sm rounded hover:bg-red-700"
                  >
                    Set Urgent
                  </button>
                  <button
                    onClick={() => handleBulkPriorityUpdate('high')}
                    className="px-3 py-1 bg-orange-600 text-white text-sm rounded hover:bg-orange-700"
                  >
                    Set High
                  </button>
                  <button
                    onClick={() => handleBulkPriorityUpdate('medium')}
                    className="px-3 py-1 bg-yellow-600 text-white text-sm rounded hover:bg-yellow-700"
                  >
                    Set Medium
                  </button>
                  <button
                    onClick={() => handleBulkPriorityUpdate('low')}
                    className="px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700"
                  >
                    Set Low
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Priority Rules */}
        <div className="space-y-6">
          {showRules && (
            <div className="bg-white rounded-lg shadow-md border border-gray-200">
              <div className="px-6 py-4 border-b border-gray-200">
                <h2 className="text-lg font-semibold text-gray-900">Priority Rules</h2>
              </div>
              <div className="divide-y divide-gray-200">
                {priorityRules.map((rule) => (
                  <div key={rule.id} className="p-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-2 mb-1">
                          <h3 className="text-sm font-medium text-gray-900">{rule.name}</h3>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                            rule.active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                          }`}>
                            {rule.active ? 'Active' : 'Inactive'}
                          </span>
                        </div>
                        <p className="text-xs text-gray-600 mb-2">{rule.description}</p>
                        <div className="text-xs text-gray-500">
                          <span className="font-medium">Priority: </span>
                          <span className={`px-1 py-0.5 rounded text-xs font-medium ${getPriorityColor(rule.priority)}`}>
                            {rule.priority.toUpperCase()}
                          </span>
                          <span className="ml-2 font-medium">Weight: </span>
                          <span>{rule.weight}</span>
                        </div>
                        <div className="mt-1">
                          <span className="text-xs font-medium text-gray-500">Conditions: </span>
                          <div className="flex flex-wrap gap-1 mt-1">
                            {rule.conditions.map((condition, index) => (
                              <span
                                key={index}
                                className="px-2 py-1 text-xs bg-gray-100 text-gray-700 rounded"
                              >
                                {condition}
                              </span>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Smart Priority Insights */}
          <div className="bg-white rounded-lg shadow-md border border-gray-200">
            <div className="px-6 py-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">Smart Priority Insights</h2>
            </div>
            <div className="p-6 space-y-4">
              <div className="flex items-center space-x-3">
                <BarChart3 className="w-5 h-5 text-blue-500" />
                <div>
                  <p className="text-sm font-medium text-gray-900">AI Confidence</p>
                  <p className="text-xs text-gray-600">Average confidence: 87%</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Target className="w-5 h-5 text-green-500" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Accuracy Rate</p>
                  <p className="text-xs text-gray-600">94% of predictions correct</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Zap className="w-5 h-5 text-yellow-500" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Auto-Applied</p>
                  <p className="text-xs text-gray-600">23 issues updated today</p>
                </div>
              </div>
              <div className="flex items-center space-x-3">
                <Shield className="w-5 h-5 text-red-500" />
                <div>
                  <p className="text-sm font-medium text-gray-900">Safety Alerts</p>
                  <p className="text-xs text-gray-600">5 urgent safety issues</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PriorityManagement;
